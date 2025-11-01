"""
Login & Register API
Flask API untuk autentikasi user dengan MD5 password hashing
"""

from flask import Flask, request, jsonify, send_from_directory
from connection import get_db_connection
from config import config
from auth import AuthService, hash_password_md5, validate_email
from image_storage_service import ImageStorageService
import traceback
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = config.secret_key

# Inisialisasi database connection
db = get_db_connection(**config.get_db_config())

# Inisialisasi Auth Service
auth_service = AuthService(db)

# Inisialisasi Image Storage Service (local storage)
image_service = ImageStorageService(db, upload_folder='uploads')


@app.route('/')
def index():
    """Homepage API"""
    return jsonify({
        'message': 'Kripto App API - MD5 Password Hashing + Steganography',
        'version': '1.0',
        'security': 'MD5 Password Hashing',
        'endpoints': {
            'users': '/api/users',
            'user_by_id': '/api/users/<id>',
            'login': '/api/login',
            'register': '/api/register',
            'change_password': '/api/change-password',
            'test_db': '/api/test-db',
            'hash_password': '/api/hash-password',
            'stego_upload': '/api/stego/upload',
            'stego_gallery': '/api/stego/gallery',
            'stego_list': '/api/stego/images/<user_id>',
            'stego_download': '/api/stego/image/<image_id>',
            'stego_decode': '/api/stego/decode/<image_id>',
            'stego_delete': '/api/stego/image/<image_id>',
            'test': '/tes/<name>'
        }
    })


@app.route('/tes/<koneksi>')
def test_endpoint(koneksi):
    """Test endpoint"""
    return jsonify({
        'message': f"Hello, {koneksi}!",
        'status': 'success'
    })


@app.route('/api/users', methods=['GET'])
def get_users():
    """Get semua users dari database"""
    try:
        # Query semua users (tanpa password untuk keamanan)
        query = "SELECT id, username, email, created_at FROM users"
        results = db.execute_read_dict(query)
        
        if results:
            return jsonify({
                'success': True,
                'count': len(results),
                'users': results
            })
        else:
            return jsonify({
                'success': True,
                'count': 0,
                'users': []
            })
    
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user_by_id(user_id):
    """Get user berdasarkan ID"""
    try:
        query = "SELECT id, username, email, created_at FROM users WHERE id = %s"
        result = db.execute_read_dict(query, (user_id,))
        
        if result:
            return jsonify({
                'success': True,
                'user': result[0]
            })
        else:
            return jsonify({
                'success': False,
                'message': 'User tidak ditemukan'
            }), 404
    
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/register', methods=['POST'])
def register():
    """Register user baru dengan MD5 password hashing"""
    try:
        data = request.get_json()
        
        # Validasi input
        if not data or not data.get('email') or not data.get('password'):
            return jsonify({
                'success': False,
                'message': 'Email dan password harus diisi'
            }), 400
        
        email = data['email']
        password = data['password']
        username = data.get('username')
        
        # Gunakan AuthService untuk register
        result = auth_service.register_user(email, password, username)
        
        if result['success']:
            return jsonify(result), 201
        else:
            return jsonify(result), 400
    
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/login', methods=['POST'])
def login():
    """Login user dengan MD5 password verification"""
    try:
        data = request.get_json()
        
        # Validasi input
        if not data or not data.get('email') or not data.get('password'):
            return jsonify({
                'success': False,
                'message': 'Email dan password harus diisi'
            }), 400
        
        email = data['email']
        password = data['password']
        
        # Gunakan AuthService untuk login
        result = auth_service.login_user(email, password)
        
        if result['success']:
            return jsonify(result), 200
        else:
            print('Login gagal:', result['message'])
            return jsonify(result), 401
    
    except Exception as e:
        print(f'Error during login: {str(e)}')
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/test-db', methods=['GET'])
def test_database():
    """Test koneksi database"""
    try:
        result = db.execute_read_query("SELECT 1 as test")
        if result:
            return jsonify({
                'success': True,
                'message': 'Koneksi database berhasil',
                'database': config.db_database
            })
        else:
            return jsonify({
                'success': False,
                'message': 'Koneksi database gagal'
            }), 500
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/change-password', methods=['POST'])
def change_password():
    """Change password user"""
    try:
        data = request.get_json()
        
        # Validasi input
        if not data or not data.get('id') or not data.get('old_password') or not data.get('new_password'):
            return jsonify({
                'success': False,
                'message': 'User ID, password lama, dan password baru harus diisi'
            }), 400
        
        user_id = data['id']
        old_password = data['old_password']
        new_password = data['new_password']
        
        # Gunakan AuthService untuk change password
        result = auth_service.change_password(user_id, old_password, new_password)
        
        if result['success']:
            return jsonify(result), 200
        else:
            return jsonify(result), 400
    
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/hash-password', methods=['POST'])
def hash_password_endpoint():
    """Endpoint untuk hash password (untuk testing/migration)"""
    try:
        data = request.get_json()
        
        if not data or not data.get('password'):
            return jsonify({
                'success': False,
                'message': 'Password harus diisi'
            }), 400
        
        password = data['password']
        hashed = hash_password_md5(password)
        
        return jsonify({
            'success': True,
            'password': password,
            'md5_hash': hashed
        })
    
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


# ==================== STEGANOGRAPHY ENDPOINTS ====================

@app.route('/api/stego/upload', methods=['POST'])
def stego_upload():
    """
    Upload gambar dengan steganografi (encode message + save to Google Drive)
    
    Request Body:
    {
        "user_id": 1,
        "image_data": "base64_encoded_image",
        "secret_message": "pesan rahasia",
        "filename": "photo.png"  // optional
    }
    """
    try:
        data = request.get_json()
        
        # Validasi input
        if not data or not data.get('user_id') or not data.get('image_data') or not data.get('secret_message'):
            return jsonify({
                'success': False,
                'message': 'user_id, image_data, dan secret_message harus diisi'
            }), 400
        
        user_id = data['user_id']
        image_data = data['image_data']
        secret_message = data['secret_message']
        filename = data.get('filename')  # Optional
        
        # Process dan save
        result = image_service.process_and_save_image(
            user_id=user_id,
            image_base64=image_data,
            secret_message=secret_message,
            original_filename=filename
        )
        
        if result['success']:
            return jsonify(result), 201
        else:
            return jsonify(result), 400
    
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/stego/gallery', methods=['GET'])
def stego_public_gallery():
    """
    Get semua gambar steganografi dari semua user (Public Gallery)
    
    Query params:
    - page (optional, default=1): Halaman
    - limit (optional, default=20): Jumlah per halaman
    
    Example: GET /api/stego/gallery?page=1&limit=20
    
    Konsep: Semua user bisa lihat gambar, tapi hanya bisa decode jika tau keynya
    """
    try:
        # Get query params
        page = request.args.get('page', default=1, type=int)
        limit = request.args.get('limit', default=20, type=int)
        
        # Validasi
        if page < 1:
            page = 1
        if limit < 1 or limit > 100:  # Max 100 per page
            limit = 20
        
        result = image_service.get_all_images_public(page=page, limit=limit)
        
        if result['success']:
            return jsonify(result), 200
        else:
            return jsonify(result), 400
    
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/stego/images/<int:user_id>', methods=['GET'])
def stego_list_user_images(user_id):
    """
    Get semua gambar steganografi milik user
    
    Example: GET /api/stego/images/1
    """
    try:
        result = image_service.get_user_images(user_id)
        
        if result['success']:
            return jsonify(result), 200
        else:
            return jsonify(result), 400
    
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/stego/image/<int:image_id>', methods=['GET'])
def stego_get_image(image_id):
    """
    Get image metadata dengan Drive links
    
    Query params: user_id (required)
    Example: GET /api/stego/image/1?user_id=1
    """
    try:
        user_id = request.args.get('user_id')
        
        if not user_id:
            return jsonify({
                'success': False,
                'message': 'user_id query parameter harus diisi'
            }), 400
        
        result = image_service.get_image_data(image_id, int(user_id))
        
        if result['success']:
            return jsonify(result), 200
        else:
            return jsonify(result), 404
    
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/stego/decode/<int:image_id>', methods=['GET'])
def stego_decode_message(image_id):
    """
    Download gambar dari Drive dan decode pesan rahasianya
    
    Query params: user_id (required)
    Example: GET /api/stego/decode/1?user_id=1
    """
    try:
        user_id = request.args.get('user_id')
        
        if not user_id:
            return jsonify({
                'success': False,
                'message': 'user_id query parameter harus diisi'
            }), 400
        
        result = image_service.decode_message(image_id, int(user_id))
        
        if result['success']:
            return jsonify(result), 200
        else:
            return jsonify(result), 404
    
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/stego/image/<int:image_id>', methods=['DELETE'])
def stego_delete_image(image_id):
    """
    Delete gambar (dari database dan Google Drive)
    
    Request Body:
    {
        "user_id": 1
    }
    """
    try:
        data = request.get_json()
        
        if not data or not data.get('user_id'):
            return jsonify({
                'success': False,
                'message': 'user_id harus diisi'
            }), 400
        
        user_id = data['user_id']
        
        result = image_service.delete_image(image_id, user_id)
        
        if result['success']:
            return jsonify(result), 200
        else:
            return jsonify(result), 404
    
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


# ==================== STATIC FILES ENDPOINT ====================

@app.route('/uploads/<filename>')
def serve_uploaded_file(filename):
    """
    Serve uploaded images (untuk akses gambar dari browser/Flutter)
    
    Example: GET /uploads/1_20251031_120000_abc123.png
    """
    try:
        # Gunakan upload_folder yang sama dengan ImageStorageService
        return send_from_directory(image_service.upload_folder, filename)
    except Exception as e:
        return jsonify({
            'success': False,
            'message': f'File not found: {str(e)}'
        }), 404


if __name__ == '__main__':
    print("\n" + "="*50)
    print("🚀 Starting Kripto App API Server")
    print("="*50)
    config.display_config()
    print(f"📁 Upload folder: {image_service.upload_folder}")
    print(f"📁 Folder exists: {os.path.exists(image_service.upload_folder)}")
    print("="*50 + "\n")
    
    app.run(
        host=config.flask_host,
        port=config.flask_port,
        debug=config.flask_debug
    )