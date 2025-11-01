"""
Login & Register API
Flask API untuk autentikasi user dengan MD5 password hashing + Stateless Steganography
"""

from flask import Flask, request, jsonify
from connection import get_db_connection
from config import config
from auth import AuthService, hash_password_md5, validate_email
import traceback

app = Flask(__name__)
app.config['SECRET_KEY'] = config.secret_key

# Inisialisasi database connection
db = get_db_connection(**config.get_db_config())

# Inisialisasi Auth Service
auth_service = AuthService(db)


@app.route('/')
def index():
    """Homepage API"""
    return jsonify({
        'message': 'Kripto App API - MD5 Password Hashing + Steganography',
        'version': '2.0',
        'security': 'MD5 Password Hashing',
        'endpoints': {
            'users': '/api/users',
            'user_by_id': '/api/users/<id>',
            'login': '/api/login',
            'register': '/api/register',
            'change_password': '/api/change-password',
            'test_db': '/api/test-db',
            'hash_password': '/api/hash-password',
            # Steganography Stateless API (No Database!)
            'stego_encode': '/api/stego/encode',  # NEW! Upload gambar + pesan → return gambar hasil
            'stego_decode': '/api/stego/decode',  # NEW! Upload gambar → return pesan
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


# ==================== STEGANOGRAPHY STATELESS API ====================
# No Database! No File Storage! Pure Processing Only!

@app.route('/api/stego/encode', methods=['POST'])
def stego_encode_stateless():
    """
    🎯 STATELESS ENCODE - Encode message ke gambar tanpa save ke database/server
    
    User upload gambar + pesan → return gambar hasil (base64) → user download sendiri
    
    Request Body:
    {
        "image_data": "base64_encoded_image",
        "secret_message": "pesan rahasia"
    }
    
    Response:
    {
        "success": true,
        "message": "Pesan berhasil disembunyikan dalam gambar",
        "data": {
            "encoded_image": "base64_encoded_result_image",
            "original_size": 1920x1080,
            "message_length": 18,
            "capacity_used": "0.002%",
            "format": "PNG"
        }
    }
    """
    try:
        data = request.get_json()
        
        # Validasi input
        if not data or not data.get('image_data') or not data.get('secret_message'):
            return jsonify({
                'success': False,
                'message': 'image_data dan secret_message harus diisi'
            }), 400
        
        image_base64 = data['image_data']
        secret_message = data['secret_message']
        
        # Clean base64 string
        if isinstance(image_base64, str):
            if 'base64,' in image_base64:
                image_base64 = image_base64.split('base64,')[1]
            image_base64 = image_base64.strip().replace('\n', '').replace('\r', '')
        
        print(f"📝 Encoding message ({len(secret_message)} chars) into image...")
        
        # Import steganography
        from utils.steganography import Steganography
        stego = Steganography()
        
        # Check capacity
        capacity_info = stego.check_capacity(image_base64)
        
        if len(secret_message) > capacity_info['max_characters']:
            return jsonify({
                'success': False,
                'message': f'Pesan terlalu panjang! Maksimal {capacity_info["max_characters"]} karakter, pesan kamu {len(secret_message)} karakter',
                'image_info': capacity_info
            }), 400
        
        # Encode message
        encoded_image_base64 = stego.encode_message(image_base64, secret_message)
        
        # Calculate capacity usage
        capacity_used_percent = (len(secret_message) / capacity_info['max_characters']) * 100
        
        print(f"✅ Message encoded successfully!")
        print(f"📊 Capacity used: {capacity_used_percent:.3f}%")
        
        return jsonify({
            'success': True,
            'message': 'Pesan berhasil disembunyikan dalam gambar',
            'data': {
                'encoded_image': encoded_image_base64,  # Base64 gambar hasil
                'image_info': {
                    'width': capacity_info['width'],
                    'height': capacity_info['height'],
                    'total_pixels': capacity_info['total_pixels'],
                    'max_capacity': capacity_info['max_characters']
                },
                'message_length': len(secret_message),
                'capacity_used_percent': round(capacity_used_percent, 3),
                'format': 'PNG',
                'note': 'Download gambar dengan decode base64 ke file PNG'
            }
        }), 200
    
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            'success': False,
            'message': f'Error: {str(e)}'
        }), 500


@app.route('/api/stego/decode', methods=['POST'])
def stego_decode_stateless():
    """
    🔓 STATELESS DECODE - Decode message dari gambar tanpa save ke database
    
    User upload gambar steganografi → return pesan rahasia
    
    Request Body:
    {
        "image_data": "base64_encoded_stego_image"
    }
    
    Response:
    {
        "success": true,
        "message": "Pesan berhasil diekstrak",
        "data": {
            "secret_message": "pesan rahasia",
            "message_length": 18,
            "image_info": {
                "width": 1920,
                "height": 1080
            }
        }
    }
    """
    try:
        data = request.get_json()
        
        # Validasi input
        if not data or not data.get('image_data'):
            return jsonify({
                'success': False,
                'message': 'image_data harus diisi'
            }), 400
        
        image_base64 = data['image_data']
        
        # Clean base64 string
        if isinstance(image_base64, str):
            if 'base64,' in image_base64:
                image_base64 = image_base64.split('base64,')[1]
            image_base64 = image_base64.strip().replace('\n', '').replace('\r', '')
        
        print(f"🔓 Decoding message from uploaded image...")
        
        # Import steganography
        from utils.steganography import Steganography
        stego = Steganography()
        
        # Get image info
        capacity_info = stego.check_capacity(image_base64)
        
        # Decode message
        secret_message = stego.decode_message(image_base64)
        
        print(f"✅ Message decoded successfully! Length: {len(secret_message)}")
        
        return jsonify({
            'success': True,
            'message': 'Pesan berhasil diekstrak',
            'data': {
                'secret_message': secret_message,
                'message_length': len(secret_message),
                'image_info': {
                    'width': capacity_info['width'],
                    'height': capacity_info['height'],
                    'total_pixels': capacity_info['total_pixels'],
                    'max_capacity': capacity_info['max_characters']
                }
            }
        }), 200
    
    except Exception as e:
        traceback.print_exc()
        return jsonify({
            'success': False,
            'message': f'Error decoding message: {str(e)}'
        }), 500


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


# ==================== SERVER STARTUP ====================

if __name__ == '__main__':
    print("\n" + "="*50)
    print("🚀 Starting Kripto App API Server")
    print("="*50)
    print("📌 Mode: Stateless Steganography (No Database Storage)")
    config.display_config()
    print("="*50 + "\n")
    
    app.run(
        host=config.flask_host,
        port=config.flask_port,
        debug=config.flask_debug
    )
