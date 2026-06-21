from flask import Flask, g
from sqlalchemy import create_engine, event
from sqlalchemy.orm import scoped_session, sessionmaker
from .config import Config

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    # Initialize SQLAlchemy engine with WAL mode
    engine = create_engine(app.config['SQLALCHEMY_DATABASE_URI'])

    @event.listens_for(engine, "connect")
    def set_sqlite_pragma(dbapi_connection, connection_record):
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA journal_mode=WAL")
        cursor.execute("PRAGMA synchronous=NORMAL")
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.close()

    # Create scoped session
    app.session = scoped_session(sessionmaker(autocommit=False, autoflush=False, bind=engine))

    @app.teardown_appcontext
    def shutdown_session(exception=None):
        app.session.remove()

    # Security Headers
    @app.after_request
    def set_security_headers(response):
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-Frame-Options'] = 'SAMEORIGIN'
        response.headers['X-XSS-Protection'] = '1; mode=block'
        # Minimal local CSP
        response.headers['Content-Security-Policy'] = "default-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'; img-src 'self' data: blob:"
        return response

    # Context Processor to inject AppConfig into templates
    @app.context_processor
    def inject_config():
        from .services.config_service import get_all_config
        config_dict = get_all_config(app.session())
        return dict(config=config_dict)

    # Register Blueprints
    from .routes.api import api_bp
    from .routes.views import views_bp
    
    app.register_blueprint(api_bp, url_prefix='/api/v1')
    app.register_blueprint(views_bp)

    return app, engine
