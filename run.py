import os
import logging
from logging.handlers import RotatingFileHandler
from waitress import serve
from app import create_app
from app.models import Base
from app.services.config_service import seed_defaults

def setup_environment():
    # Base directories
    base_dir = os.path.dirname(os.path.abspath(__file__))
    dirs_to_create = [
        os.path.join(base_dir, 'app', 'static', 'uploads'),
        os.path.join(base_dir, 'app', 'static', 'css'),
        os.path.join(base_dir, 'app', 'static', 'js'),
        os.path.join(base_dir, 'app', 'static', 'fonts'),
        os.path.join(base_dir, 'app', 'static', 'icons'),
        os.path.join(base_dir, 'logs'),
        os.path.join(base_dir, 'db')
    ]
    
    for d in dirs_to_create:
        os.makedirs(d, exist_ok=True)
        
    # Logging configuration
    log_file = os.path.join(base_dir, 'logs', 'app.log')
    handler = RotatingFileHandler(log_file, maxBytes=5*1024*1024, backupCount=3)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler.setFormatter(formatter)
    
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)
    
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)
    root_logger.addHandler(handler)
    root_logger.addHandler(console_handler)

if __name__ == '__main__':
    setup_environment()
    
    logger = logging.getLogger('bootstrapper')
    logger.info("Initializing application...")
    
    app, engine = create_app()
    
    # Initialize DB
    with app.app_context():
        Base.metadata.create_all(engine)
        seed_defaults(app.session())
        
    logger.info("*" * 50)
    logger.info("Starting production server (Waitress)")
    logger.info("URL: http://0.0.0.0:8080")
    logger.info("*" * 50)
    
    serve(app, host='0.0.0.0', port=8080, threads=4)
