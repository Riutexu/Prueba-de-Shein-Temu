from flask import Blueprint, render_template, current_app, request, abort
from ..services import catalog, config_service, filters

views_bp = Blueprint('views', __name__)

@views_bp.route('/')
def index():
    session = current_app.session()
    
    page = request.args.get('page', 1, type=int)
    category_id = request.args.get('category_id', type=int)
    search = request.args.get('search')
    sort_field = request.args.get('sort_field')
    sort_dir = request.args.get('sort_dir')
    
    products, pagination = catalog.get_products(
        session, page=page, per_page=12, category_id=category_id, 
        search=search, sort_field=sort_field, sort_dir=sort_dir, active_only=True
    )
    
    categories = catalog.get_categories(session)
    visible_filters = filters.get_visible_filters(session)
    
    return render_template('index.html', 
        products=products, 
        categories=categories, 
        filters=visible_filters, 
        pagination=pagination,
        current_category=category_id,
        current_search=search,
        current_sort=sort_field,
        current_dir=sort_dir
    )

@views_bp.route('/product/<slug>')
def product_detail(slug):
    session = current_app.session()
    product = catalog.get_product_by_slug(session, slug)
    
    if not product or not product.is_active:
        abort(404)
        
    related, _ = catalog.get_products(
        session, page=1, per_page=4, category_id=product.category_id, active_only=True
    )
    related = [p for p in related if p.id != product.id][:4]
    
    return render_template('product.html', product=product, related_products=related)

@views_bp.route('/admin')
def admin_dashboard():
    session = current_app.session()
    stats = catalog.get_dashboard_stats(session)
    return render_template('admin/dashboard.html', stats=stats)

@views_bp.route('/admin/products')
def admin_products():
    session = current_app.session()
    page = request.args.get('page', 1, type=int)
    products, pagination = catalog.get_products(session, page, 20, active_only=False)
    categories = catalog.get_all_categories_flat(session)
    return render_template('admin/products.html', products=products, categories=categories, pagination=pagination)

@views_bp.route('/admin/categories')
def admin_categories():
    session = current_app.session()
    categories = catalog.get_categories(session) # hierarchical
    flat_categories = catalog.get_all_categories_flat(session)
    return render_template('admin/categories.html', categories=categories, flat_categories=flat_categories)

@views_bp.route('/admin/filters')
def admin_filters():
    session = current_app.session()
    all_filters = filters.get_all_filters(session)
    return render_template('admin/filters.html', filters=all_filters)

@views_bp.route('/admin/settings')
def admin_settings():
    session = current_app.session()
    config = config_service.get_all_config(session)
    return render_template('admin/settings.html', config=config)
