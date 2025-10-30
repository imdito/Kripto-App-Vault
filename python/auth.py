"""
Authentication Module
Modul untuk hashing password dengan MD5 dan autentikasi user
"""

import hashlib
import re


def hash_password_md5(password):
    """
    Hash password menggunakan MD5.
    
    Args:
        password: Password plaintext (string)
    
    Returns:
        Hashed password dalam format hexadecimal
    
    Example:
        >>> hash_password_md5("password123")
        '482c811da5d5b4bc6d497ffa98491e38'
    """
    # Konversi password ke bytes
    password_bytes = password.encode('utf-8')

    # Hash dengan MD5
    md5_hash = hashlib.md5(password_bytes)

    # Return dalam format hexadecimal
    return md5_hash.hexdigest()


def verify_password_md5(password, hashed_password):
    """
    Verifikasi password dengan hash MD5.
    
    Args:
        password: Password plaintext yang diinput user
        hashed_password: Hash MD5 yang tersimpan di database
    
    Returns:
        True jika cocok, False jika tidak
    
    Example:
        >>> hashed = hash_password_md5("password123")
        >>> verify_password_md5("password123", hashed)
        True
        >>> verify_password_md5("wrongpass", hashed)
        False
    """
    # Hash password yang diinput
    password_hash = hash_password_md5(password)

    # Bandingkan dengan hash dari database
    return password_hash == hashed_password


def validate_email(email):
    """
    Validasi format email.
    
    Args:
        email: Email string
    
    Returns:
        True jika valid, False jika tidak
    
    Example:
        >>> validate_email("user@example.com")
        True
        >>> validate_email("invalid-email")
        False
    """
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None


def validate_password_strength(password):
    """
    Validasi kekuatan password.
    
    Args:
        password: Password string
    
    Returns:
        Dictionary dengan status dan message
    
    Example:
        >>> validate_password_strength("pass")
        {'valid': False, 'message': 'Password minimal 6 karakter'}
    """
    if len(password) < 6:
        return {
            'valid': False,
            'message': 'Password minimal 6 karakter'
        }

    if len(password) > 100:
        return {
            'valid': False,
            'message': 'Password maksimal 100 karakter'
        }

    return {
        'valid': True,
        'message': 'Password valid'
    }


class AuthService:
    """Service untuk mengelola autentikasi user."""

    def __init__(self, db_connection):
        """
        Inisialisasi AuthService.
        
        Args:
            db_connection: Database connection object dari connection.py
        """
        self.db = db_connection

    def register_user(self, email, password, username=None):
        """
        Register user baru dengan MD5 password hashing.
        
        Args:
            email: Email user
            password: Password plaintext
            username: Username (opsional, default dari email)
        
        Returns:
            Dictionary dengan status dan message
        """
        # Validasi email
        if not validate_email(email):
            return {
                'success': False,
                'message': 'Format email tidak valid'
            }

        # Validasi password
        password_check = validate_password_strength(password)
        if not password_check['valid']:
            return {
                'success': False,
                'message': password_check['message']
            }

        # Set username default jika tidak ada
        if not username:
            username = email.split('@')[0]

        # Cek apakah email sudah terdaftar
        check_query = "SELECT id FROM users WHERE email = %s"
        existing = self.db.execute_read_one(check_query, (email,))

        if existing:
            return {
                'success': False,
                'message': 'Email sudah terdaftar'
            }

        # Hash password dengan MD5
        hashed_password = hash_password_md5(password)

        # Insert user baru
        insert_query = """
        INSERT INTO users (username, email, password_hash) 
        VALUES (%s, %s, %s)
        """

        success = self.db.execute_query(insert_query, (username, email, hashed_password))

        if success:
            return {
                'success': True,
                'message': 'Registrasi berhasil',
                'username': username
            }
        else:
            return {
                'success': False,
                'message': 'Registrasi gagal, coba lagi'
            }

    def login_user(self, email, password):
        """
        Login user dengan verifikasi MD5 password.
        
        Args:
            email: Email user
            password: Password plaintext
        
        Returns:
            Dictionary dengan status, message, dan data user (jika berhasil)
        """
        # Cari user berdasarkan email
        query = "SELECT id, username, email, password_hash FROM users WHERE email = %s"
        result = self.db.execute_read_dict(query, (email,))

        if not result:
            return {
                'success': False,
                'message': 'Email atau password salah'
            }

        user = result[0]

        # Verifikasi password dengan MD5
        if verify_password_md5(password, user.get('password_hash')):
            return {
                'success': True,
                'message': 'Login berhasil',
                'user': {
                    'id': user['id'],
                    'username': user['username'],
                    'email': user['email']
                }
            }
        else:
            return {
                'success': False,
                'message': 'Email atau password salah'
            }

    def change_password(self, user_id, old_password, new_password):
        """
        Ubah password user.

        Args:
            user_id: ID user
            old_password: Password lama
            new_password: Password baru

        Returns:
            Dictionary dengan status dan message
        """
        # Validasi password baru
        password_check = validate_password_strength(new_password)
        if not password_check['valid']:
            return {
                'success': False,
                'message': password_check['message']
            }

        # Ambil data user
        query = "SELECT password_hash FROM users WHERE id = %s"
        result = self.db.execute_read_dict(query, (user_id,))

        if not result:
            return {
                'success': False,
                'message': 'User tidak ditemukan'
            }

        user = result[0]

        # Verifikasi password lama
        if not verify_password_md5(old_password, user.get('password_hash')):
            return {
                'success': False,
                'message': 'Password lama salah'
            }

        # Hash password baru
        new_hashed = hash_password_md5(new_password)

        # Update password
        update_query = "UPDATE users SET password_hash = %s WHERE id = %s"
        success = self.db.execute_query(update_query, (new_hashed, user_id))

        if success:
            return {
                'success': True,
                'message': 'Password berhasil diubah'
            }
        else:
            return {
                'success': False,
                'message': 'Gagal mengubah password'
            }


# Testing
if __name__ == "__main__":
    print("=== Test MD5 Password Hashing ===\n")

    # Test 1: Hash password
    password = "password123"
    hashed = hash_password_md5(password)
    print(f"1. Hash Password:")
    print(f"   Password: {password}")
    print(f"   MD5 Hash: {hashed}")

    # Test 2: Verify correct password
    print(f"\n2. Verify Correct Password:")
    is_valid = verify_password_md5("password123", hashed)
    print(f"   Result: {is_valid}")

    # Test 3: Verify wrong password
    print(f"\n3. Verify Wrong Password:")
    is_valid = verify_password_md5("wrongpassword", hashed)
    print(f"   Result: {is_valid}")

    # Test 4: Email validation
    print(f"\n4. Email Validation:")
    print(f"   user@example.com: {validate_email('user@example.com')}")
    print(f"   invalid-email: {validate_email('invalid-email')}")

    # Test 5: Password strength
    print(f"\n5. Password Strength:")
    print(f"   'pass': {validate_password_strength('pass')}")
    print(f"   'password123': {validate_password_strength('password123')}")
