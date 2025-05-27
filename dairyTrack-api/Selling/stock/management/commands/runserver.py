# from django.core.management.commands.runserver import Command as RunserverCommand
# from stock.utils import run_background_tasks
# import threading

# class Command(RunserverCommand):
#     def handle(self, *args, **options):
#         # Mulai tugas latar belakang dalam thread terpisah
#         task_thread = threading.Thread(target=run_background_tasks, daemon=True)
#         task_thread.start()
#         # Jalankan perintah runserver seperti biasa
#         super().handle(*args, **options)