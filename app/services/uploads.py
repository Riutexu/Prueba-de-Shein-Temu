import os
import uuid

ALLOWED_MIME_TYPES = {'image/jpeg', 'image/png', 'image/gif', 'image/webp'}

def validate_image(file_storage) -> bool:
    header = file_storage.read(12)
    file_storage.seek(0)
    
    if not header:
        return False
        
    # JPEG: FF D8 FF
    if header.startswith(b'\xff\xd8\xff'):
        return True
    # PNG: 89 50 4E 47
    if header.startswith(b'\x89PNG\r\n\x1a\n'):
        return True
    # GIF: 47 49 46 38
    if header.startswith(b'GIF87a') or header.startswith(b'GIF89a'):
        return True
    # WEBP: RIFF...WEBP
    if header.startswith(b'RIFF') and header[8:12] == b'WEBP':
        return True
        
    return False

def save_upload(file_storage, upload_dir: str) -> str | None:
    if not file_storage or not file_storage.filename:
        return None
        
    if not validate_image(file_storage):
        return None

    # Extensión segura
    ext = os.path.splitext(file_storage.filename)[1].lower()
    if ext not in ['.jpg', '.jpeg', '.png', '.gif', '.webp']:
        ext = '.jpg'

    filename = f"{uuid.uuid4().hex}{ext}"
    filepath = os.path.join(upload_dir, filename)
    file_storage.save(filepath)
    
    return filename

def delete_upload(filename: str, upload_dir: str) -> bool:
    if not filename:
        return False
        
    # Prevenir path traversal
    safe_filename = os.path.basename(filename)
    filepath = os.path.join(upload_dir, safe_filename)
    
    if os.path.exists(filepath):
        os.remove(filepath)
        return True
    return False
