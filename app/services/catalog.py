import unicodedata
import re
from sqlalchemy.orm import Session
from sqlalchemy import or_, func
from ..models import Product, Category
from .filters import apply_filters

def generate_slug(name: str) -> str:
    slug = unicodedata.normalize('NFKD', name).encode('ascii', 'ignore').decode('utf-8')
    slug = re.sub(r'[^\w\s-]', '', slug).strip().lower()
    return re.sub(r'[-\s]+', '-', slug)

def get_products(session: Session, page: int, per_page: int, category_id: int = None, search: str = None, sort_field: str = None, sort_dir: str = None, active_only: bool = True):
    query = session.query(Product)
    if active_only:
        query = query.filter(Product.is_active == True)
        
    if category_id:
        query = query.filter(Product.category_id == category_id)
        
    if search:
        search_term = f"%{search}%"
        query = query.filter(or_(Product.name.ilike(search_term), Product.description.ilike(search_term)))
        
    if sort_field and sort_dir:
        query = apply_filters(query, sort_field, sort_dir)
    else:
        query = query.order_by(Product.created_at.desc())
        
    total = query.count()
    pages = (total + per_page - 1) // per_page
    items = query.offset((page - 1) * per_page).limit(per_page).all()
    
    pagination = {
        'page': page,
        'pages': pages,
        'total': total,
        'per_page': per_page
    }
    
    return items, pagination

def get_product_by_slug(session: Session, slug: str) -> Product | None:
    return session.query(Product).filter_by(slug=slug).first()

def get_product_by_id(session: Session, id: int) -> Product | None:
    return session.query(Product).get(id)

def create_product(session: Session, data: dict) -> Product:
    slug = generate_slug(data['name'])
    # Ensure unique slug
    base_slug = slug
    counter = 1
    while session.query(Product).filter_by(slug=slug).first():
        slug = f"{base_slug}-{counter}"
        counter += 1
        
    p = Product(
        name=data['name'],
        slug=slug,
        description=data.get('description'),
        price=data['price'],
        stock=data.get('stock', 0),
        sku=data.get('sku'),
        image_path=data.get('image_path'),
        category_id=data.get('category_id'),
        is_active=data.get('is_active', True)
    )
    session.add(p)
    session.commit()
    return p

def update_product(session: Session, id: int, data: dict) -> Product | None:
    p = session.query(Product).get(id)
    if not p:
        return None
        
    if 'name' in data and data['name'] != p.name:
        slug = generate_slug(data['name'])
        base_slug = slug
        counter = 1
        while session.query(Product).filter(Product.slug == slug, Product.id != id).first():
            slug = f"{base_slug}-{counter}"
            counter += 1
        p.slug = slug
        p.name = data['name']

    if 'description' in data: p.description = data['description']
    if 'price' in data: p.price = data['price']
    if 'stock' in data: p.stock = data['stock']
    if 'sku' in data: p.sku = data['sku']
    if 'image_path' in data: p.image_path = data['image_path']
    if 'category_id' in data: p.category_id = data['category_id']
    if 'is_active' in data: p.is_active = data['is_active']
    
    session.commit()
    return p

def delete_product(session: Session, id: int) -> bool:
    p = session.query(Product).get(id)
    if not p:
        return False
    session.delete(p)
    session.commit()
    return True

def get_categories(session: Session) -> list[Category]:
    return session.query(Category).filter_by(parent_id=None).order_by(Category.position).all()

def get_all_categories_flat(session: Session) -> list[Category]:
    return session.query(Category).order_by(Category.position).all()

def get_category_by_id(session: Session, id: int) -> Category | None:
    return session.query(Category).get(id)

def create_category(session: Session, data: dict) -> Category:
    slug = generate_slug(data['name'])
    base_slug = slug
    counter = 1
    while session.query(Category).filter_by(slug=slug).first():
        slug = f"{base_slug}-{counter}"
        counter += 1

    c = Category(
        name=data['name'],
        slug=slug,
        description=data.get('description'),
        parent_id=data.get('parent_id'),
        position=data.get('position', 0)
    )
    session.add(c)
    session.commit()
    return c

def update_category(session: Session, id: int, data: dict) -> Category | None:
    c = session.query(Category).get(id)
    if not c:
        return None
        
    if 'name' in data and data['name'] != c.name:
        slug = generate_slug(data['name'])
        base_slug = slug
        counter = 1
        while session.query(Category).filter(Category.slug == slug, Category.id != id).first():
            slug = f"{base_slug}-{counter}"
            counter += 1
        c.slug = slug
        c.name = data['name']

    if 'description' in data: c.description = data['description']
    if 'parent_id' in data: c.parent_id = data['parent_id']
    if 'position' in data: c.position = data['position']
    
    session.commit()
    return c

def delete_category(session: Session, id: int) -> bool:
    c = session.query(Category).get(id)
    if not c:
        return False
    session.delete(c)
    session.commit()
    return True

def get_dashboard_stats(session: Session) -> dict:
    total_products = session.query(Product).count()
    active_products = session.query(Product).filter_by(is_active=True).count()
    total_categories = session.query(Category).count()
    low_stock = session.query(Product).filter(Product.stock < 10, Product.is_active == True).count()
    
    return {
        'total_products': total_products,
        'active_products': active_products,
        'total_categories': total_categories,
        'low_stock': low_stock
    }
