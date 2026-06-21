from flask import Blueprint, current_app, request, jsonify
from decimal import Decimal
import logging
import os

from ..services import catalog, config_service, filters, uploads

api_bp = Blueprint('api', __name__)
logger = logging.getLogger(__name__)

def make_response(success=True, data=None, error=None, pagination=None):
    return jsonify({
        "success": success,
        "data": data,
        "error": error,
        "pagination": pagination
    })

# --- PRODUCTS ---

@api_bp.route('/products', methods=['GET'])
def get_products():
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 12, type=int)
        category_id = request.args.get('category_id', type=int)
        search = request.args.get('search')
        sort_field = request.args.get('sort_field')
        sort_dir = request.args.get('sort_dir')
        active_only = request.args.get('active_only', 'true').lower() == 'true'

        items, pagination = catalog.get_products(
            current_app.session(), page, per_page, category_id, search, sort_field, sort_dir, active_only
        )
        
        data = [{
            'id': p.id,
            'name': p.name,
            'slug': p.slug,
            'description': p.description,
            'price': str(p.price),
            'stock': p.stock,
            'sku': p.sku,
            'image_path': p.image_path,
            'category_id': p.category_id,
            'is_active': p.is_active,
            'category_name': p.category.name if p.category else None
        } for p in items]
        
        return make_response(data=data, pagination=pagination)
    except Exception as e:
        logger.error(f"Error in GET /products: {e}")
        return make_response(success=False, error=str(e)), 500

@api_bp.route('/products', methods=['POST'])
def create_product():
    try:
        data = request.form.to_dict()
        
        # Handle file upload if present
        image_path = None
        if 'image' in request.files:
            file = request.files['image']
            image_path = uploads.save_upload(file, current_app.config['UPLOAD_FOLDER'])
            if image_path:
                data['image_path'] = image_path
                
        # Convert numeric types
        data['price'] = Decimal(data['price'])
        if 'stock' in data: data['stock'] = int(data['stock'])
        if 'category_id' in data and data['category_id']:
            data['category_id'] = int(data['category_id'])
        else:
             data['category_id'] = None
        if 'is_active' in data: data['is_active'] = data['is_active'] == 'true'

        p = catalog.create_product(current_app.session(), data)
        return make_response(data={'id': p.id, 'slug': p.slug})
    except Exception as e:
        logger.error(f"Error in POST /products: {e}")
        return make_response(success=False, error=str(e)), 500

@api_bp.route('/products/<int:id>', methods=['GET'])
def get_product(id):
    try:
        p = catalog.get_product_by_id(current_app.session(), id)
        if not p:
            return make_response(success=False, error="Not found"), 404
            
        data = {
            'id': p.id, 'name': p.name, 'slug': p.slug, 'description': p.description,
            'price': str(p.price), 'stock': p.stock, 'sku': p.sku, 'image_path': p.image_path,
            'category_id': p.category_id, 'is_active': p.is_active
        }
        return make_response(data=data)
    except Exception as e:
        return make_response(success=False, error=str(e)), 500

@api_bp.route('/products/<int:id>', methods=['PUT'])
def update_product(id):
    try:
        # Check if form data or json
        if request.is_json:
            data = request.json
        else:
            data = request.form.to_dict()
            if 'image' in request.files:
                file = request.files['image']
                image_path = uploads.save_upload(file, current_app.config['UPLOAD_FOLDER'])
                if image_path:
                    # Retrieve old to delete
                    old_p = catalog.get_product_by_id(current_app.session(), id)
                    if old_p and old_p.image_path:
                        uploads.delete_upload(old_p.image_path, current_app.config['UPLOAD_FOLDER'])
                    data['image_path'] = image_path

        if 'price' in data: data['price'] = Decimal(data['price'])
        if 'stock' in data: data['stock'] = int(data['stock'])
        if 'category_id' in data: 
            data['category_id'] = int(data['category_id']) if data['category_id'] else None
        if 'is_active' in data: data['is_active'] = str(data['is_active']).lower() == 'true'

        p = catalog.update_product(current_app.session(), id, data)
        if not p:
            return make_response(success=False, error="Not found"), 404
        return make_response(data={'id': p.id})
    except Exception as e:
        logger.error(f"Error in PUT /products/{id}: {e}")
        return make_response(success=False, error=str(e)), 500

@api_bp.route('/products/<int:id>', methods=['DELETE'])
def delete_product(id):
    try:
        p = catalog.get_product_by_id(current_app.session(), id)
        if p and p.image_path:
            uploads.delete_upload(p.image_path, current_app.config['UPLOAD_FOLDER'])
            
        success = catalog.delete_product(current_app.session(), id)
        if not success:
            return make_response(success=False, error="Not found"), 404
        return make_response()
    except Exception as e:
        logger.error(f"Error in DELETE /products/{id}: {e}")
        return make_response(success=False, error=str(e)), 500

# --- CATEGORIES ---

@api_bp.route('/categories', methods=['GET'])
def get_categories():
    try:
        cats = catalog.get_all_categories_flat(current_app.session())
        data = [{'id': c.id, 'name': c.name, 'slug': c.slug, 'parent_id': c.parent_id, 'position': c.position} for c in cats]
        return make_response(data=data)
    except Exception as e:
        return make_response(success=False, error=str(e)), 500

@api_bp.route('/categories', methods=['POST'])
def create_category():
    try:
        data = request.json
        if data.get('parent_id'): data['parent_id'] = int(data['parent_id'])
        c = catalog.create_category(current_app.session(), data)
        return make_response(data={'id': c.id})
    except Exception as e:
        return make_response(success=False, error=str(e)), 500

@api_bp.route('/categories/<int:id>', methods=['GET', 'PUT', 'DELETE'])
def category_operations(id):
    try:
        if request.method == 'GET':
            c = catalog.get_category_by_id(current_app.session(), id)
            if not c: return make_response(success=False, error="Not found"), 404
            return make_response(data={'id': c.id, 'name': c.name, 'slug': c.slug, 'parent_id': c.parent_id, 'description': c.description, 'position': c.position})
        
        elif request.method == 'PUT':
            data = request.json
            if data.get('parent_id'): data['parent_id'] = int(data['parent_id'])
            c = catalog.update_category(current_app.session(), id, data)
            if not c: return make_response(success=False, error="Not found"), 404
            return make_response(data={'id': c.id})
            
        elif request.method == 'DELETE':
            success = catalog.delete_category(current_app.session(), id)
            if not success: return make_response(success=False, error="Not found"), 404
            return make_response()
    except Exception as e:
        return make_response(success=False, error=str(e)), 500

# --- FILTERS ---

@api_bp.route('/filters', methods=['GET'])
def get_filters():
    try:
        flts = filters.get_all_filters(current_app.session())
        data = [{'id': f.id, 'name': f.name, 'field': f.field, 'direction': f.direction, 'is_visible': f.is_visible, 'position': f.position} for f in flts]
        return make_response(data=data)
    except Exception as e:
        return make_response(success=False, error=str(e)), 500

@api_bp.route('/filters', methods=['POST'])
def create_filter():
    try:
        f = filters.create_filter(current_app.session(), request.json)
        return make_response(data={'id': f.id})
    except Exception as e:
        return make_response(success=False, error=str(e)), 500

@api_bp.route('/filters/<int:id>', methods=['PUT', 'DELETE'])
def filter_operations(id):
    try:
        if request.method == 'PUT':
            f = filters.update_filter(current_app.session(), id, request.json)
            if not f: return make_response(success=False, error="Not found"), 404
            return make_response(data={'id': f.id})
        elif request.method == 'DELETE':
            success = filters.delete_filter(current_app.session(), id)
            if not success: return make_response(success=False, error="Not found"), 404
            return make_response()
    except Exception as e:
        return make_response(success=False, error=str(e)), 500

# --- CONFIG ---

@api_bp.route('/config', methods=['GET', 'PUT'])
def config_operations():
    try:
        if request.method == 'GET':
            data = config_service.get_all_config(current_app.session())
            return make_response(data=data)
        elif request.method == 'PUT':
            data = request.json
            for k, v in data.items():
                config_service.set_config(current_app.session(), k, str(v))
            return make_response()
    except Exception as e:
        return make_response(success=False, error=str(e)), 500

# --- UPLOAD ---

@api_bp.route('/upload', methods=['POST'])
def upload_file():
    try:
        if 'image' not in request.files:
            return make_response(success=False, error="No image provided"), 400
        file = request.files['image']
        filename = uploads.save_upload(file, current_app.config['UPLOAD_FOLDER'])
        if filename:
            return make_response(data={'path': filename})
        return make_response(success=False, error="Invalid file"), 400
    except Exception as e:
        return make_response(success=False, error=str(e)), 500
