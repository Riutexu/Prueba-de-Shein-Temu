from sqlalchemy.orm import Session
from ..models import AppConfig

def get_all_config(session: Session) -> dict:
    configs = session.query(AppConfig).all()
    return {c.key: c.value for c in configs}

def get_config(session: Session, key: str) -> str | None:
    config = session.query(AppConfig).filter_by(key=key).first()
    return config.value if config else None

def set_config(session: Session, key: str, value: str) -> None:
    config = session.query(AppConfig).filter_by(key=key).first()
    if config:
        config.value = value
    else:
        config = AppConfig(key=key, value=value)
        session.add(config)
    session.commit()

def seed_defaults(session: Session) -> None:
    defaults = {
        'site_name': 'Mi Tienda',
        'primary_color': '#6366f1',
        'secondary_color': '#8b5cf6',
        'accent_color': '#f59e0b',
        'bg_color': '#ffffff',
        'text_color': '#1e293b',
        'currency_symbol': '$',
        'currency_code': 'USD'
    }
    
    existing = get_all_config(session)
    if not existing:
        for key, value in defaults.items():
            session.add(AppConfig(key=key, value=value))
        session.commit()
