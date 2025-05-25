from app.models.notification import Notification
from app.models.daily_milk_summary import DailyMilkSummary
from app.database.database import db
from datetime import date, datetime, timedelta
from app.models.cows import Cow
from app.models.milk_batches import MilkBatch, MilkStatus
from app.socket import emit_notification
import logging
import time
from functools import wraps
from flask import current_app
from sqlalchemy import and_, func
from app.models.user_cow_association import user_cow_association

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Configuration
class NotificationConfig:
    NOTIFICATION_BATCH_SIZE = 100
    RATE_LIMIT_PER_USER = 50
    RATE_LIMIT_WINDOW_MINUTES = 60
    CLEANUP_DAYS = 30
    MAX_RETRIES = 3
    SOCKET_TIMEOUT = 30
    WARNING_HOURS = 4  # Hours before expiry to send warning

# Rate Limiter
class NotificationRateLimiter:
    def __init__(self):
        self.user_limits = {}
    
    def is_rate_limited(self, user_id, limit=50, window_minutes=60):
        """Check if user has exceeded notification rate limit"""
        now = datetime.now()
        
        if user_id not in self.user_limits:
            self.user_limits[user_id] = {'count': 0, 'reset_time': now + timedelta(minutes=window_minutes)}
            
        user_data = self.user_limits[user_id]
        
        if now > user_data['reset_time']:
            user_data['count'] = 0
            user_data['reset_time'] = now + timedelta(minutes=window_minutes)
        
        if user_data['count'] >= limit:
            return True
            
        user_data['count'] += 1
        return False

# Global rate limiter instance
rate_limiter = NotificationRateLimiter()

# Decorator for tracking metrics
def track_notification_metrics(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        try:
            result = func(*args, **kwargs)
            execution_time = time.time() - start_time
            logging.info(f"Notification function {func.__name__} completed in {execution_time:.2f}s")
            return result
        except Exception as e:
            logging.error(f"Notification function {func.__name__} failed: {str(e)}")
            raise
    return wrapper

def validate_notification_access(user_id, cow_id):
    """Validate user has access to cow notifications"""
    association = db.session.query(user_cow_association).filter_by(
        user_id=user_id, 
        cow_id=cow_id
    ).first()
    
    if not association:
        logging.warning(f"Unauthorized notification access attempt: user {user_id} for cow {cow_id}")
        return False
    return True

def sanitize_notification_message(message):
    """Sanitize notification message to prevent XSS"""
    import html
    return html.escape(message)

@track_notification_metrics
def check_milk_production_and_notify():
    """
    Checks if milk production is within the standard range (15-25 liters/day)
    and notifies farmers accordingly. Updates existing notifications instead of creating duplicates.
    """
    with current_app.app_context():
        today = date.today()
        notification_count = 0
        
        logging.info("Starting milk production check for date: %s", today)
        
        try:
            daily_summaries = DailyMilkSummary.query.filter_by(date=today).all()
            logging.info("Found %d daily milk summaries for today", len(daily_summaries))
            
            # Collect data for admin summary
            low_production_cows = []
            high_production_cows = []
            total_production = 0
            
            for summary in daily_summaries:
                logging.info("Processing summary for cow ID: %d, total volume: %.2f", 
                           summary.cow_id, summary.total_volume)
                
                total_production += summary.total_volume
                message = None
                notification_type = None
                
                if summary.total_volume < 15:
                    message = f"Produksi susu rendah! Sapi #{summary.cow.id} ({summary.cow.name}) " \
                              f"hanya memproduksi {summary.total_volume} liter hari ini (di bawah standar 15L)"
                    notification_type = "low_production"
                    low_production_cows.append(summary)
                    
                elif summary.total_volume > 25:
                    message = f"Produksi susu tinggi! Sapi #{summary.cow.id} ({summary.cow.name}) " \
                              f"memproduksi {summary.total_volume} liter hari ini (di atas standar 25L)"
                    notification_type = "high_production"
                    high_production_cows.append(summary)
                
                if message and notification_type:
                    count = create_or_update_production_notifications(
                        summary.cow_id, message, notification_type, today
                    )
                    notification_count += count
            
            # Create admin summary for production
            if low_production_cows or high_production_cows:
                admin_count = create_production_admin_summary(
                    total_production, low_production_cows, high_production_cows, today
                )
                notification_count += admin_count
            
            logging.info("Milk production check completed. Total notifications processed: %d", notification_count)
            return notification_count
            
        except Exception as e:
            logging.error("Error in check_milk_production_and_notify: %s", str(e))
            db.session.rollback()
            return 0

def create_or_update_production_notifications(cow_id, message, notification_type, date):
    """
    Create notifications for users who manage the cow with improved error handling
    """
    try:
        cow_managers = db.session.query(user_cow_association).filter_by(cow_id=cow_id).all()
        
        if not cow_managers:
            logging.warning("No managers found for cow ID: %d", cow_id)
            return 0
        
        notification_count = 0
        
        for manager_relation in cow_managers:
            user_id = manager_relation.user_id
            
            # Rate limiting check
            if rate_limiter.is_rate_limited(user_id):
                logging.warning(f"Rate limit exceeded for user {user_id}")
                continue
            
            # Check for existing notification today
            today_start = datetime.combine(date, datetime.min.time())
            existing_notification = Notification.query.filter_by(
                user_id=user_id,
                cow_id=cow_id,
                type=notification_type
            ).filter(
                Notification.created_at >= today_start
            ).first()
            
            if existing_notification:
                # Update existing notification
                existing_notification.message = sanitize_notification_message(message)
                existing_notification.is_read = False
                existing_notification.created_at = datetime.utcnow()
                logging.info("Updated existing notification for user %d, cow %d", user_id, cow_id)
            else:
                # Create new notification
                notification = Notification(
                    user_id=user_id,
                    cow_id=cow_id,
                    message=sanitize_notification_message(message),
                    type=notification_type,
                    is_read=False
                )
                db.session.add(notification)
                logging.info("Created new notification for user %d, cow %d", user_id, cow_id)
            
            # Emit real-time notification
            emit_notification_safe(user_id, {
                'cow_id': cow_id,
                'message': message,
                'type': notification_type,
                'is_read': False,
                'created_at': datetime.now().isoformat()
            })
            
            notification_count += 1
        
        if notification_count > 0:
            db.session.commit()
        
        return notification_count
        
    except Exception as e:
        logging.error("Error creating production notifications: %s", str(e))
        db.session.rollback()
        return 0

def emit_notification_safe(user_id, notification_data):
    """Emit notification with error handling and retry"""
    max_retries = NotificationConfig.MAX_RETRIES
    
    for attempt in range(max_retries):
        try:
            emit_notification(user_id, notification_data)
            logging.info("Notification emitted successfully to user %d", user_id)
            break
        except Exception as e:
            if attempt == max_retries - 1:
                logging.error("Failed to emit notification after %d attempts: %s", max_retries, str(e))
            else:
                logging.warning(f"Emit attempt {attempt + 1} failed: {e}, retrying...")
                time.sleep(1)

@track_notification_metrics
def check_milk_expiry_and_notify():
    """
    Enhanced milk expiry check with admin notifications and better error handling
    """
    with current_app.app_context():
        current_time = datetime.utcnow()
        notification_count = 0
        
        logging.info("Starting milk expiry check at: %s", current_time)
        
        try:
            # Process expired batches
            expired_count = process_expired_batches(current_time)
            notification_count += expired_count
            
            # Process warning batches
            warning_count = process_warning_batches(current_time)
            notification_count += warning_count
            
            # Create admin summary for expiry
            admin_count = create_expiry_admin_summary(current_time)
            notification_count += admin_count
            
            if notification_count > 0:
                db.session.commit()
                logging.info("Milk expiry notifications committed to database")
            
            logging.info("Milk expiry check completed. Total notifications created: %d", notification_count)
            return notification_count
            
        except Exception as e:
            logging.error("Error in check_milk_expiry_and_notify: %s", str(e))
            db.session.rollback()
            return 0

def process_expired_batches(current_time):
    """Process expired milk batches and notify managers"""
    expired_batches = MilkBatch.query.filter(
        MilkBatch.status == MilkStatus.FRESH,
        MilkBatch.expiry_date < current_time
    ).all()
    
    logging.info("Found %d expired milk batches", len(expired_batches))
    notification_count = 0
    
    for batch in expired_batches:
        try:
            logging.info("Processing expired batch ID: %d", batch.id)
            batch.status = MilkStatus.EXPIRED
            
            expiry_time = batch.expiry_date.strftime("%H:%M:%S on %d/%m/%Y")
            sessions = batch.milking_sessions
            
            if not sessions:
                logging.warning("No milking sessions found for batch ID: %d", batch.id)
                continue
                
            cow_ids = set(session.cow_id for session in sessions)
            
            for cow_id in cow_ids:
                cow = Cow.query.get(cow_id)
                if not cow:
                    logging.warning("Cow with ID %d not found", cow_id)
                    continue
                    
                managers = cow.managers.all()
                
                for manager in managers:
                    # Rate limiting check
                    if rate_limiter.is_rate_limited(manager.id):
                        continue
                        
                    message = f"Batch {batch.batch_number} dengan {batch.total_volume} liter dari sapi {cow.name} telah kadaluarsa pada {expiry_time}."
                    
                    notification = Notification(
                        user_id=manager.id,
                        cow_id=cow_id,
                        message=sanitize_notification_message(message),
                        type="milk_expiry",
                        is_read=False
                    )
                    db.session.add(notification)
                    
                    emit_notification_safe(manager.id, {
                        'cow_id': cow_id,
                        'message': message,
                        'type': "milk_expiry",
                        'is_read': False,
                        'created_at': datetime.now().isoformat()
                    })
                    
                    notification_count += 1
                    
        except Exception as e:
            logging.error(f"Error processing expired batch {batch.id}: {str(e)}")
            continue
    
    return notification_count

def process_warning_batches(current_time):
    """Process batches that will expire soon and send warnings"""
    warning_time = current_time + timedelta(hours=NotificationConfig.WARNING_HOURS)
    warning_batches = MilkBatch.query.filter(
        MilkBatch.status == MilkStatus.FRESH,
        MilkBatch.expiry_date <= warning_time,
        MilkBatch.expiry_date > current_time
    ).all()
    
    logging.info("Found %d batches that will expire within %d hours", 
                len(warning_batches), NotificationConfig.WARNING_HOURS)
    notification_count = 0
    
    for batch in warning_batches:
        try:
            logging.info("Processing warning batch ID: %d", batch.id)
            
            time_remaining = batch.expiry_date - current_time
            hours_remaining = time_remaining.total_seconds() / 3600
            expiry_time = batch.expiry_date.strftime("%H:%M:%S on %d/%m/%Y")
            
            sessions = batch.milking_sessions
            if not sessions:
                logging.warning("No milking sessions found for batch ID: %d", batch.id)
                continue
                
            cow_ids = set(session.cow_id for session in sessions)
            
            for cow_id in cow_ids:
                cow = Cow.query.get(cow_id)
                if not cow:
                    logging.warning("Cow with ID %d not found", cow_id)
                    continue
                    
                managers = cow.managers.all()
                
                for manager in managers:
                    # Check if warning already sent today
                    today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
                    existing_notification = Notification.query.filter_by(
                        user_id=manager.id,
                        cow_id=cow_id,
                        type="milk_warning"
                    ).filter(
                        Notification.message.contains(f"Batch {batch.batch_number}"),
                        Notification.created_at >= today_start
                    ).first()
                    
                    if existing_notification:
                        logging.info("Warning notification already sent today for batch %s to manager %d", 
                                   batch.batch_number, manager.id)
                        continue
                    
                    # Rate limiting check
                    if rate_limiter.is_rate_limited(manager.id):
                        continue
                    
                    message = f"PERINGATAN: Batch {batch.batch_number} dengan {batch.total_volume} liter dari sapi {cow.name} akan kadaluarsa dalam {hours_remaining:.1f} jam pada {expiry_time}. Segera gunakan atau olah!"
                    
                    notification = Notification(
                        user_id=manager.id,
                        cow_id=cow_id,
                        message=sanitize_notification_message(message),
                        type="milk_warning",
                        is_read=False
                    )
                    db.session.add(notification)
                    
                    emit_notification_safe(manager.id, {
                        'cow_id': cow_id,
                        'message': message,
                        'type': "milk_warning",
                        'is_read': False,
                        'created_at': datetime.now().isoformat()
                    })
                    
                    notification_count += 1
                    
        except Exception as e:
            logging.error(f"Error processing warning batch {batch.id}: {str(e)}")
            continue
    
    return notification_count

def create_admin_notifications(message, notification_type, cow_id=None, priority="medium"):
    """
    Create notifications for all admin users with enhanced error handling
    """
    try:
        from app.models.user import User
        
        admin_users = User.query.filter_by(role='admin').all()
        
        if not admin_users:
            logging.warning("No admin users found in system")
            return 0
        
        notification_count = 0
        
        for admin in admin_users:
            try:
                # Rate limiting for admin
                if rate_limiter.is_rate_limited(admin.id, limit=100):  # Higher limit for admin
                    continue
                
                notification = Notification(
                    user_id=admin.id,
                    cow_id=cow_id,
                    message=sanitize_notification_message(f"[ADMIN] {message}"),
                    type=f"admin_{notification_type}",
                    is_read=False
                )
                db.session.add(notification)
                
                emit_notification_safe(admin.id, {
                    'id': None,
                    'user_id': admin.id,
                    'cow_id': cow_id,
                    'message': f"[ADMIN] {message}",
                    'type': f"admin_{notification_type}",
                    'priority': priority,
                    'is_read': False,
                    'created_at': datetime.now().isoformat()
                })
                
                notification_count += 1
                
            except Exception as e:
                logging.error(f"Error creating notification for admin {admin.id}: {str(e)}")
                continue
                
        if notification_count > 0:
            db.session.commit()
            logging.info(f"Created {notification_count} admin notifications")
            
        return notification_count
        
    except Exception as e:
        logging.error(f"Error creating admin notifications: {str(e)}")
        db.session.rollback()
        return 0

def create_production_admin_summary(total_production, low_production_cows, high_production_cows, today):
    """Create admin summary for production data"""
    try:
        total_cows = Cow.query.count()
        avg_production = total_production / total_cows if total_cows > 0 else 0
        
        summary_message = f"""
📊 RINGKASAN PRODUKSI HARIAN ({today.strftime('%d/%m/%Y')})

🐄 Total Sapi: {total_cows}
🥛 Produksi Hari Ini: {total_production:.1f}L (Rata-rata: {avg_production:.1f}L/sapi)

⚠️ Perhatian Produksi:
• {len(low_production_cows)} sapi produksi rendah (<15L)
• {len(high_production_cows)} sapi produksi tinggi (>25L)

Detail Sapi Bermasalah:
{get_cow_details_summary(low_production_cows, high_production_cows)}
        """.strip()
        
        priority = "critical" if len(low_production_cows) > 5 else "high"
        
        return create_admin_notifications(
            summary_message,
            "production_summary",
            priority=priority
        )
        
    except Exception as e:
        logging.error(f"Error creating production admin summary: {str(e)}")
        return 0

def create_expiry_admin_summary(current_time):
    """Create admin summary for milk expiry data"""
    try:
        expired_batches = MilkBatch.query.filter(
            MilkBatch.status == MilkStatus.EXPIRED,
            func.date(MilkBatch.expiry_date) == current_time.date()
        ).all()
        
        warning_time = current_time + timedelta(hours=NotificationConfig.WARNING_HOURS)
        warning_batches = MilkBatch.query.filter(
            MilkBatch.status == MilkStatus.FRESH,
            MilkBatch.expiry_date <= warning_time,
            MilkBatch.expiry_date > current_time
        ).all()
        
        fresh_batches = MilkBatch.query.filter_by(status=MilkStatus.FRESH).count()
        
        if expired_batches or warning_batches:
            expired_volume = sum(b.total_volume for b in expired_batches)
            warning_volume = sum(b.total_volume for b in warning_batches)
            
            summary_message = f"""
🥛 RINGKASAN STATUS SUSU ({current_time.strftime('%d/%m/%Y %H:%M')})

📊 Status Batch:
• {fresh_batches} batch susu segar tersedia
• {len(expired_batches)} batch KADALUARSA hari ini ({expired_volume:.1f}L)
• {len(warning_batches)} batch AKAN KADALUARSA dalam {NotificationConfig.WARNING_HOURS} jam ({warning_volume:.1f}L)

💰 Estimasi Kerugian: Rp {(expired_volume * 8000):,.0f}
⚡ Tindakan Diperlukan: {len(warning_batches)} batch perlu segera diproses
            """.strip()
            
            priority = "critical" if len(expired_batches) > 3 else "high"
            
            return create_admin_notifications(
                summary_message,
                "expiry_summary",
                priority=priority
            )
        
        return 0
        
    except Exception as e:
        logging.error(f"Error creating expiry admin summary: {str(e)}")
        return 0

def get_cow_details_summary(low_production_cows, high_production_cows):
    """Get formatted summary of problematic cows"""
    details = []
    
    if low_production_cows:
        details.append("Produksi Rendah:")
        for cow_summary in low_production_cows[:5]:  # Limit to 5
            details.append(f"  • {cow_summary.cow.name}: {cow_summary.total_volume:.1f}L")
        if len(low_production_cows) > 5:
            details.append(f"  • ... dan {len(low_production_cows) - 5} sapi lainnya")
    
    if high_production_cows:
        if details:
            details.append("")
        details.append("Produksi Tinggi:")
        for cow_summary in high_production_cows[:3]:  # Limit to 3
            details.append(f"  • {cow_summary.cow.name}: {cow_summary.total_volume:.1f}L")
        if len(high_production_cows) > 3:
            details.append(f"  • ... dan {len(high_production_cows) - 3} sapi lainnya")
    
    return "\n".join(details) if details else "Tidak ada detail tersedia"

def create_daily_admin_summary():
    """
    Create comprehensive daily summary notification for admin
    """
    try:
        today = date.today()
        
        # Production data
        daily_summaries = DailyMilkSummary.query.filter_by(date=today).all()
        total_production = sum(s.total_volume for s in daily_summaries)
        total_cows = Cow.query.count()
        avg_production = total_production / total_cows if total_cows > 0 else 0
        
        low_production_cows = [s for s in daily_summaries if s.total_volume < 15]
        high_production_cows = [s for s in daily_summaries if s.total_volume > 25]
        
        # Milk batches data
        fresh_batches = MilkBatch.query.filter_by(status=MilkStatus.FRESH).count()
        expired_today = MilkBatch.query.filter(
            MilkBatch.status == MilkStatus.EXPIRED,
            func.date(MilkBatch.expiry_date) == today
        ).count()
        
        # System health metrics
        total_notifications_today = Notification.query.filter(
            func.date(Notification.created_at) == today
        ).count()
        
        summary_message = f"""
📊 RINGKASAN HARIAN FARM ({today.strftime('%d %B %Y')})

🐄 PRODUKSI SUSU:
• Total Sapi: {total_cows}
• Produksi Hari Ini: {total_production:.1f}L
• Rata-rata per Sapi: {avg_production:.1f}L
• Target Harian: {total_cows * 20:.1f}L

⚠️ MONITORING:
• {len(low_production_cows)} sapi produksi rendah (<15L)
• {len(high_production_cows)} sapi produksi tinggi (>25L)
• {fresh_batches} batch susu segar
• {expired_today} batch kadaluarsa hari ini

📱 SISTEM:
• {total_notifications_today} notifikasi dikirim hari ini
• Status sistem: {"Baik" if total_notifications_today < 100 else "Tinggi"}

💡 REKOMENDASI:
{get_daily_recommendations(low_production_cows, high_production_cows, expired_today)}
        """.strip()
        
        return create_admin_notifications(
            summary_message,
            "daily_summary",
            priority="high"
        )
        
    except Exception as e:
        logging.error(f"Error creating daily admin summary: {str(e)}")
        return 0

def get_daily_recommendations(low_production_cows, high_production_cows, expired_today):
    """Generate daily recommendations for admin"""
    recommendations = []
    
    if len(low_production_cows) > 3:
        recommendations.append("• Periksa kesehatan sapi dengan produksi rendah")
        recommendations.append("• Evaluasi pakan dan kondisi kandang")
    
    if len(high_production_cows) > 2:
        recommendations.append("• Monitor sapi produksi tinggi untuk stress")
        recommendations.append("• Pastikan asupan nutrisi mencukupi")
    
    if expired_today > 2:
        recommendations.append("• Review proses handling susu")
        recommendations.append("• Pertimbangkan optimasi jadwal distribusi")
    
    if not recommendations:
        recommendations.append("• Pertahankan performa operasional yang baik")
        recommendations.append("• Lakukan maintenance rutin peralatan")
    
    return "\n".join(recommendations)

def create_critical_admin_alert(message, alert_type, cow_id=None):
    """
    Create high-priority alerts for admin with immediate attention flags
    """
    critical_message = f"🚨 CRITICAL ALERT: {message}"
    
    return create_admin_notifications(
        critical_message,
        f"critical_{alert_type}",
        cow_id=cow_id,
        priority="critical"
    )

def create_notification(user_id, message, notification_type, additional_data=None):
    """Create notification and send via socket"""
    try:
        notification = Notification(
            user_id=user_id,
            message=message,
            type=notification_type,
            is_read=False,
            created_at=datetime.utcnow()
        )
        
        if additional_data:
            notification.additional_data = json.dumps(additional_data)
        
        db.session.add(notification)
        db.session.commit()
        
        # Send via socket immediately after saving
        notification_data = {
            'id': notification.id,
            'user_id': notification.user_id,
            'message': notification.message,
            'type': notification.type,
            'is_read': notification.is_read,
            'created_at': notification.created_at.isoformat(),
            'additional_data': additional_data
        }
        
        # Send to user via socket
        emit_notification_safe(user_id, notification_data)
        
        logging.info(f"Notification created and sent to user {user_id}")
        return notification
        
    except Exception as e:
        logging.error(f"Error creating notification: {str(e)}")
        db.session.rollback()
        return None

def create_notifications_for_cow(cow_id, message, notification_type):
    """Creates notifications for all farmers managing the specified cow (for non-production notifications)"""
    
    logging.info("Creating notifications for cow ID: %d", cow_id)
    
    cow = Cow.query.get(cow_id)
    count = 0
    
    if not cow:
        logging.warning("Cow with ID %d not found", cow_id)
        return count
    
    try:
        managers = cow.managers.all()
        logging.info("Found %d managers for cow ID: %d", len(managers), cow_id)
        
        for manager in managers:
            # Rate limiting check
            if rate_limiter.is_rate_limited(manager.id):
                continue
                
            logging.info("Creating notification for manager ID: %d", manager.id)
            notification = Notification(
                user_id=manager.id,
                cow_id=cow_id,
                message=sanitize_notification_message(message),
                type=notification_type,
                is_read=False
            )
            db.session.add(notification)
            
            emit_notification_safe(manager.id, {
                'cow_id': cow_id,
                'message': message,
                'type': notification_type,
                'is_read': False,
                'created_at': datetime.now().isoformat()
            })
            
            count += 1
        
        if count > 0:
            db.session.commit()
            logging.info("Notifications committed to database")
        
        return count
        
    except Exception as e:
        logging.error("Error creating notifications for cow %d: %s", cow_id, str(e))
        db.session.rollback()
        return 0

def cleanup_old_notifications():
    """Remove notifications older than configured days"""
    try:
        cutoff_date = datetime.now() - timedelta(days=NotificationConfig.CLEANUP_DAYS)
        old_notifications = Notification.query.filter(
            Notification.created_at < cutoff_date
        ).delete()
        db.session.commit()
        logging.info(f"Cleaned up {old_notifications} old notifications")
        return old_notifications
    except Exception as e:
        logging.error(f"Error cleaning up notifications: {str(e)}")
        db.session.rollback()
        return 0

def get_notification_stats():
    """Get notification statistics for monitoring"""
    try:
        today = date.today()
        stats = {
            'total_today': Notification.query.filter(
                func.date(Notification.created_at) == today
            ).count(),
            'unread_count': Notification.query.filter_by(is_read=False).count(),
            'by_type': {}
        }
        
        # Count by type
        types = ['milk_expiry', 'milk_warning', 'low_production', 'high_production']
        for ntype in types:
            stats['by_type'][ntype] = Notification.query.filter(
                Notification.type == ntype,
                func.date(Notification.created_at) == today
            ).count()
        
        return stats
    except Exception as e:
        logging.error(f"Error getting notification stats: {str(e)}")
        return {}

# Legacy function for backward compatibility
def emit_notification_to_user(user_id, notification):
    """Emit notification via socket to specific user (legacy)"""
    notification_data = {
        'id': notification.id,
        'user_id': notification.user_id,
        'cow_id': notification.cow_id,
        'message': notification.message,
        'type': notification.type,
        'is_read': notification.is_read,
        'created_at': notification.created_at.isoformat() if notification.created_at else None
    }
    
    emit_notification_safe(user_id, notification_data)

@track_notification_metrics
def check_milk_usage_and_notify():
    """
    Check for milk batches that have been used and notify relevant users
    """
    with current_app.app_context():
        notification_count = 0
        
        logging.info("Starting milk usage notification check")
        
        try:
            # Get batches that recently changed to USED status
            # Assuming you have a way to track when status changed
            recently_used_batches = MilkBatch.query.filter(
                MilkBatch.status == MilkStatus.USED,
                # Add condition to check recently changed (last 24 hours)
                MilkBatch.updated_at >= datetime.utcnow() - timedelta(hours=24)
            ).all()
            
            logging.info("Found %d recently used milk batches", len(recently_used_batches))
            
            for batch in recently_used_batches:
                try:
                    # Process each used batch
                    usage_count = process_used_batch_notifications(batch)
                    notification_count += usage_count
                    
                except Exception as e:
                    logging.error(f"Error processing used batch {batch.id}: {str(e)}")
                    continue
            
            # Create admin summary for batch usage
            if recently_used_batches:
                admin_count = create_usage_admin_summary(recently_used_batches)
                notification_count += admin_count
            
            if notification_count > 0:
                db.session.commit()
                logging.info("Milk usage notifications committed to database")
            
            logging.info("Milk usage check completed. Total notifications created: %d", notification_count)
            return notification_count
            
        except Exception as e:
            logging.error("Error in check_milk_usage_and_notify: %s", str(e))
            db.session.rollback()
            return 0
        
def process_used_batch_notifications(batch):
    """Process notifications for a used milk batch"""
    notification_count = 0
    
    try:
        logging.info("Processing used batch ID: %d", batch.id)
        
        usage_time = batch.updated_at or datetime.utcnow()
        usage_time_str = usage_time.strftime("%H:%M:%S on %d/%m/%Y")
        
        # Get milking sessions associated with this batch
        sessions = batch.milking_sessions
        
        if not sessions:
            logging.warning("No milking sessions found for batch ID: %d", batch.id)
            return 0
            
        cow_ids = set(session.cow_id for session in sessions)
        
        for cow_id in cow_ids:
            cow = Cow.query.get(cow_id)
            if not cow:
                logging.warning("Cow with ID %d not found", cow_id)
                continue
                
            managers = cow.managers.all()
            
            for manager in managers:
                # Rate limiting check
                if rate_limiter.is_rate_limited(manager.id):
                    continue
                
                # Check if notification already sent today for this batch
                today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)
                existing_notification = Notification.query.filter_by(
                    user_id=manager.id,
                    cow_id=cow_id,
                    type="milk_used"
                ).filter(
                    Notification.message.contains(f"Batch {batch.batch_number}"),
                    Notification.created_at >= today_start
                ).first()
                
                if existing_notification:
                    logging.info("Usage notification already sent for batch %s to manager %d", 
                               batch.batch_number, manager.id)
                    continue
                
                # Calculate time between production and usage
                time_to_use = usage_time - batch.created_at if batch.created_at else None
                time_to_use_str = ""
                if time_to_use:
                    hours = int(time_to_use.total_seconds() / 3600)
                    time_to_use_str = f" (digunakan setelah {hours} jam dari produksi)"
                
                message = f"✅ BATCH DIGUNAKAN: Batch {batch.batch_number} dengan {batch.total_volume} liter dari sapi {cow.name} telah digunakan pada {usage_time_str}{time_to_use_str}."
                
                notification = Notification(
                    user_id=manager.id,
                    cow_id=cow_id,
                    message=sanitize_notification_message(message),
                    type="milk_used",
                    is_read=False
                )
                db.session.add(notification)
                
                emit_notification_safe(manager.id, {
                    'cow_id': cow_id,
                    'message': message,
                    'type': "milk_used",
                    'is_read': False,
                    'created_at': datetime.now().isoformat()
                })
                
                notification_count += 1
                
    except Exception as e:
        logging.error(f"Error processing used batch {batch.id}: {str(e)}")
        
    return notification_count

def create_usage_admin_summary(used_batches):
    """Create admin summary for batch usage"""
    try:
        total_volume_used = sum(batch.total_volume for batch in used_batches)
        total_batches_used = len(used_batches)
        
        # Calculate efficiency metrics
        avg_volume_per_batch = total_volume_used / total_batches_used if total_batches_used > 0 else 0
        
        # Group by time periods
        today_usage = [b for b in used_batches if b.updated_at and b.updated_at.date() == datetime.utcnow().date()]
        
        summary_message = f"""
📊 RINGKASAN PENGGUNAAN SUSU ({datetime.utcnow().strftime('%d/%m/%Y')})

✅ BATCH DIGUNAKAN:
• {total_batches_used} batch telah digunakan (24 jam terakhir)
• {len(today_usage)} batch digunakan hari ini
• Total volume: {total_volume_used:.1f}L
• Rata-rata per batch: {avg_volume_per_batch:.1f}L

📈 EFISIENSI:
• Tingkat pemanfaatan: Baik
• Minimalisasi waste: Optimal

💡 INSIGHT:
• Manajemen batch inventory efektif
• Pola konsumsi teratur
        """.strip()
        
        return create_admin_notifications(
            summary_message,
            "usage_summary",
            priority="medium"
        )
        
    except Exception as e:
        logging.error(f"Error creating usage admin summary: {str(e)}")
        return 0

def create_batch_usage_notification(batch_id, cow_id, message):
    """
    Create notification when a milk batch is marked as USED
    Can be called from the API endpoint that updates batch status
    """
    try:
        cow = Cow.query.get(cow_id)
        if not cow:
            logging.warning("Cow with ID %d not found", cow_id)
            return 0
            
        managers = cow.managers.all()
        notification_count = 0
        
        for manager in managers:
            # Rate limiting check
            if rate_limiter.is_rate_limited(manager.id):
                continue
                
            notification = Notification(
                user_id=manager.id,
                cow_id=cow_id,
                message=sanitize_notification_message(message),
                type="milk_used",
                is_read=False
            )
            db.session.add(notification)
            
            emit_notification_safe(manager.id, {
                'cow_id': cow_id,
                'message': message,
                'type': "milk_used",
                'is_read': False,
                'created_at': datetime.now().isoformat()
            })
            
            notification_count += 1
        
        if notification_count > 0:
            db.session.commit()
            
        return notification_count
        
    except Exception as e:
        logging.error(f"Error creating batch usage notification: {str(e)}")
        db.session.rollback()
        return 0

# Tambahkan function untuk dipanggil dari API
def notify_batch_status_change(batch_id, old_status, new_status):
    """
    Notify users when batch status changes
    Call this from your API endpoint that updates batch status
    """
    try:
        batch = MilkBatch.query.get(batch_id)
        if not batch:
            return 0
            
        notification_count = 0
        
        if new_status == MilkStatus.USED and old_status != MilkStatus.USED:
            # Batch marked as USED
            sessions = batch.milking_sessions
            if sessions:
                for session in sessions:
                    message = f"✅ Batch {batch.batch_number} ({batch.total_volume}L) dari sapi {session.cow.name if session.cow else 'Unknown'} telah digunakan."
                    
                    count = create_batch_usage_notification(
                        batch_id, 
                        session.cow_id, 
                        message
                    )
                    notification_count += count
                    
        elif new_status == MilkStatus.EXPIRED and old_status != MilkStatus.EXPIRED:
            # Handle expiry (already implemented)
            pass
            
        return notification_count
        
    except Exception as e:
        logging.error(f"Error in notify_batch_status_change: {str(e)}")
        return 0