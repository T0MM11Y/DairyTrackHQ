from django.apps import AppConfig


class StockConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'stock'

    def ready(self):
            import stock.tasks
    # def ready(self):
    #     from .tasks import check_expiring_and_expired_products
    #     check_expiring_and_expired_products(repeat=60)  # Jalankan setiap 60 detik
