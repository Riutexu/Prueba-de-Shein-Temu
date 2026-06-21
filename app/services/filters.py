from sqlalchemy.orm import Session
from sqlalchemy import asc, desc
from ..models import CustomFilter, SORTABLE_FIELDS

def get_visible_filters(session: Session) -> list[CustomFilter]:
    return session.query(CustomFilter).filter_by(is_visible=True).order_by(CustomFilter.position).all()

def get_all_filters(session: Session) -> list[CustomFilter]:
    return session.query(CustomFilter).order_by(CustomFilter.position).all()

def create_filter(session: Session, data: dict) -> CustomFilter:
    if data['field'] not in SORTABLE_FIELDS:
        raise ValueError("Invalid filter field")
    
    new_filter = CustomFilter(
        name=data['name'],
        field=data['field'],
        direction=data['direction'],
        is_visible=data.get('is_visible', True),
        position=data.get('position', 0)
    )
    session.add(new_filter)
    session.commit()
    return new_filter

def update_filter(session: Session, filter_id: int, data: dict) -> CustomFilter | None:
    f = session.query(CustomFilter).get(filter_id)
    if not f:
        return None
    
    if 'field' in data and data['field'] not in SORTABLE_FIELDS:
        raise ValueError("Invalid filter field")

    f.name = data.get('name', f.name)
    f.field = data.get('field', f.field)
    f.direction = data.get('direction', f.direction)
    f.is_visible = data.get('is_visible', f.is_visible)
    f.position = data.get('position', f.position)
    
    session.commit()
    return f

def delete_filter(session: Session, filter_id: int) -> bool:
    f = session.query(CustomFilter).get(filter_id)
    if not f:
        return False
    session.delete(f)
    session.commit()
    return True

def apply_filters(query, sort_field: str, sort_dir: str):
    if sort_field in SORTABLE_FIELDS:
        field_attr = SORTABLE_FIELDS[sort_field]
        if sort_dir.upper() == 'DESC':
            return query.order_by(desc(field_attr))
        else:
            return query.order_by(asc(field_attr))
    return query
