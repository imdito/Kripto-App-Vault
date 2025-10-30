"""
Login & Register API
Flask API untuk autentikasi user dengan MD5 password hashing
"""

from flask import Flask, request, jsonify
from connection import get_db_connection
from config import config
from auth import AuthService, hash_password_md5, validate_email

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
        'message': 'Kripto App API - MD5 Password Hashing',
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
        if not data or not data.get('user_id') or not data.get('old_password') or not data.get('new_password'):
            return jsonify({
                'success': False,
                'message': 'User ID, password lama, dan password baru harus diisi'
            }), 400
        
        user_id = data['user_id']
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


if __name__ == '__main__':
    print("\n" + "="*50)
    print("🚀 Starting Kripto App API Server")
    print("="*50)
    config.display_config()
    
    app.run(
        host=config.flask_host,
        port=config.flask_port,
        debug=config.flask_debug
    )