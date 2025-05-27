from django.utils import timezone
from django.db import transaction
from background_task import background
from stock.models import ProductStock, StockHistory
from notifications.models import Notification
from datetime import timedelta
import logging

logger = logging.getLogger(__name__)

@background(schedule=60)
def check_product_expiration():
    logger.info("Starting product expiration check at %s", timezone.now())
    now = timezone.now()
    four_hours = now + timedelta(hours=4)
    two_hours = now + timedelta(hours=2)
    
    products = ProductStock.objects.filter(status="available")
    logger.info("Found %d available products to check", products.count())
    
    if not products.exists():
        logger.info("No available products to process")
        return
    
    with transaction.atomic():
        for product in products:
            time_to_expiry = product.expiry_at - now
            logger.debug("Checking product %s: expiry_at=%s, time_to_expiry=%s", 
                         product.id, product.expiry_at, time_to_expiry)
            
            # Check if expiration is within 4 hours
            if time_to_expiry <= timedelta(hours=4) and time_to_expiry > timedelta(hours=2):
                if not Notification.objects.filter(
                    product_stock=product,
                    type='EXPIRY_WARN_4H',
                    message__contains="expires in less than 4 hours"
                ).exists():
                    Notification.objects.create(
                        product_stock=product,
                        user_id=2,
                        message=f"Produk {product.product_type} expires in less than 4 hours on {product.expiry_at}!",
                        type='EXPIRY_WARN_4H',  # 14 characters
                        is_read=False
                    )
                    logger.info("Sent 4-hour warning for product %s", product.id)
            
            # Check if expiration is within 2 hours
            elif time_to_expiry <= timedelta(hours=2) and time_to_expiry > timedelta(seconds=0):
                if not Notification.objects.filter(
                    product_stock=product,
                    type='EXPIRY_WARN_2H',
                    message__contains="expires in less than 2 hours"
                ).exists():
                    Notification.objects.create(
                        product_stock=product,
                        user_id=2,
                        message=f"Produk {product.product_type} expires in less than 2 hours on {product.expiry_at}!",
                        type='EXPIRY_WARN_2H',  # 14 characters
                        is_read=False
                    )
                    logger.info("Sent 2-hour warning for product %s", product.id)
            
            # Check if product has expired
            elif product.expiry_at <= now:
                product.status = "expired"
                StockHistory.objects.create(
                    product_stock=product,
                    change_type="expired",
                    quantity_change=product.quantity
                )
                product.save()
                if not Notification.objects.filter(
                    product_stock=product,
                    type='PROD_EXPIRED'
                ).exists():
                    Notification.objects.create(
                        product_stock=product,
                        user_id=2,
                        message=f"Produk {product.product_type} telah kadaluarsa pada {product.expiry_at}!",
                        type='PROD_EXPIRED',  # 12 characters
                        is_read=False
                    )
                    logger.info("Marked product %s as expired and notified", product.id)