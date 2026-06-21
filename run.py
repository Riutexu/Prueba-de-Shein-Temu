import os
import logging
import threading  # Necesario para el hilo secundario
import webbrowser # Necesario para abrir el navegador
from logging.handlers import RotatingFileHandler
from waitress import serve
from app import create_app
from app.models import Base
from app.services.config_service import seed_defaults

# Configura el entorno previo al arranque de la aplicación.
def setup_environment():
    """Configura variables de entorno antes de iniciar la aplicación."""
    os.environ.setdefault('FLASK_ENV', 'production')

def open_browser():
    """Lanza el navegador apuntando al puerto del servidor."""
    # Espera un margen de seguridad para asegurar que Waitress ya esté escuchando
    webbrowser.open_new("http://127.0.0.1:8080")

if __name__ == '__main__':
    setup_environment()
    
    logger = logging.getLogger('bootstrapper')
    logger.info("Initializing application...")
    
    app, engine = create_app()
    
    with app.app_context():
        Base.metadata.create_all(engine)
        seed_defaults(app.session())
        
    logger.info("*" * 50)
    logger.info("Starting production server (Waitress)")
    logger.info("URL: http://127.0.0.1:8080")
    logger.info("*" * 50)

    # --- INYECCIÓN DE LANZAMIENTO AUTOMÁTICO ---
    # Inicia un hilo que espera 1.5 segundos y luego abre el navegador.
    # Esto corre en paralelo mientras Waitress toma el control del hilo principal.
    threading.Timer(1.5, open_browser).start()
    
    # Este comando bloquea la ejecución, por eso el Timer debe ser paralelo
    serve(app, host='0.0.0.0', port=8080, threads=4)