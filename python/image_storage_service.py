"""
Image Storage Service
Service untuk menyimpan dan mengelola gambar steganografi secara lokal
"""

from utils.steganography import Steganography
from datetime import datetime
import os
import base64
import hashlib


class ImageStorageService:
    """Service untuk encode pesan ke gambar dan simpan ke local storage"""
    
    def __init__(self, db_connection, upload_folder='uploads'):
        """
        Inisialisasi service
        
        Args:
            db_connection: Database connection object
            upload_folder: Folder untuk menyimpan gambar
        """
        self.db = db_connection
        self.stego = Steganography()
        self.upload_folder = upload_folder
        
        # Buat folder uploads jika belum ada
        if not os.path.exists(upload_folder):
            os.makedirs(upload_folder)
            print(f"✅ Created upload folder: {upload_folder}")
    
    def process_and_save_image(self, user_id, image_base64, secret_message, original_filename=None):
        """
        Process gambar dengan steganografi dan simpan ke local storage
        
        Steps:
        1. Encode secret message ke dalam gambar (LSB steganography)
        2. Save gambar ke folder uploads/
        3. Save metadata (user_id, filepath) ke database
        
        Args:
            user_id: ID user yang upload
            image_base64: Gambar original dalam format base64
            secret_message: Pesan rahasia yang akan disembunyikan
            original_filename: Nama file original (optional)
            
        Returns:
            Dictionary dengan status dan info file
        """
        try:
            # Validasi input
            if not image_base64 or not secret_message:
                return {
                    'success': False,
                    'message': 'Image dan secret message harus diisi'
                }
            
            # Validasi user exists
            user_check = self.db.execute_read_one(
                "SELECT id FROM users WHERE id = %s",
                (user_id,)
            )
            
            if not user_check:
                return {
                    'success': False,
                    'message': 'User tidak ditemukan'
                }
            
            # Step 1: Check capacity
            capacity = self.stego.check_capacity(image_base64)
            if len(secret_message) > capacity['max_characters']:
                return {
                    'success': False,
                    'message': f'Pesan terlalu panjang! Maksimal {capacity["max_characters"]} karakter, pesan kamu {len(secret_message)} karakter'
                }
            
            print(f"📝 Encoding message ({len(secret_message)} chars) into image...")
            
            # Step 2: Encode message ke dalam gambar
            encoded_image_base64 = self.stego.encode_message(image_base64, secret_message)
            
            print(f"✅ Message encoded successfully!")
            
            # Step 3: Generate unique filename
            if not original_filename:
                timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                original_filename = f'stego_{user_id}_{timestamp}.png'
            
            # Pastikan filename berakhiran .png (LSB butuh lossless format)
            if not original_filename.lower().endswith('.png'):
                original_filename = original_filename.rsplit('.', 1)[0] + '.png'
            
            # Generate unique filename dengan hash
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            file_hash = hashlib.md5(encoded_image_base64.encode()).hexdigest()[:8]
            unique_filename = f"{user_id}_{timestamp}_{file_hash}.png"
            
            filepath = os.path.join(self.upload_folder, unique_filename)
            
            print(f"💾 Saving to local storage: {filepath}...")
            
            # Step 4: Decode base64 dan save ke file
            image_bytes = base64.b64decode(encoded_image_base64)
            
            with open(filepath, 'wb') as f:
                f.write(image_bytes)
            
            file_size = os.path.getsize(filepath)
            
            print(f"✅ Saved to disk! Size: {file_size} bytes")
            
            # Step 5: Save metadata ke database
            insert_query = """
            INSERT INTO steganography_images (user_id, image_path)
            VALUES (%s, %s)
            """
            
            success = self.db.execute_query(insert_query, (user_id, unique_filename))
            
            if not success:
                # Rollback: hapus file jika DB insert gagal
                if os.path.exists(filepath):
                    os.remove(filepath)
                    print("❌ Database insert failed, file deleted")
                return {
                    'success': False,
                    'message': 'Gagal menyimpan metadata ke database'
                }
            
            # Get inserted ID
            get_id_query = "SELECT LAST_INSERT_ID() as id"
            result = self.db.execute_read_one(get_id_query)
            inserted_id = result[0] if result else None
            
            print(f"✅ Metadata saved to database! ID: {inserted_id}")
            
            return {
                'success': True,
                'message': 'Gambar berhasil diproses dan disimpan',
                'data': {
                    'id': inserted_id,
                    'user_id': user_id,
                    'filename': unique_filename,
                    'original_filename': original_filename,
                    'filepath': filepath,
                    'file_size': file_size,
                    'message_length': len(secret_message),
                    'image_capacity': capacity['max_characters'],
                    'url': f'/uploads/{unique_filename}'  # URL untuk akses file
                }
            }
            
        except Exception as e:
            print(f"❌ Error processing image: {str(e)}")
            import traceback
            traceback.print_exc()
            return {
                'success': False,
                'message': f'Error: {str(e)}'
            }
    
    def get_user_images(self, user_id):
        """
        Get semua gambar steganografi milik user
        
        Args:
            user_id: ID user
            
        Returns:
            Dictionary dengan list gambar
        """
        try:
            query = """
            SELECT id, user_id, image_path, created_at
            FROM steganography_images
            WHERE user_id = %s
            ORDER BY created_at DESC
            """
            
            results = self.db.execute_read_dict(query, (user_id,))
            
            # Add file info
            if results:
                for img in results:
                    filepath = os.path.join(self.upload_folder, img['image_path'])
                    if os.path.exists(filepath):
                        img['file_size'] = os.path.getsize(filepath)
                        img['url'] = f'/uploads/{img["image_path"]}'
                    else:
                        img['file_size'] = 0
                        img['url'] = None
            
            return {
                'success': True,
                'count': len(results) if results else 0,
                'images': results if results else []
            }
            
        except Exception as e:
            print(f"❌ Error getting user images: {str(e)}")
            return {
                'success': False,
                'message': str(e)
            }
    
    def get_all_images_public(self, page=1, limit=20):
        """
        Get semua gambar dari semua user (Public Gallery)
        
        Args:
            page: Halaman (untuk pagination)
            limit: Jumlah gambar per halaman
            
        Returns:
            Dictionary dengan list semua gambar
        """
        try:
            offset = (page - 1) * limit
            
            # Query dengan JOIN ke users untuk ambil username
            query = """
            SELECT 
                si.id,
                si.user_id,
                si.image_path,
                si.created_at,
                u.username
            FROM steganography_images si
            JOIN users u ON si.user_id = u.id
            ORDER BY si.created_at DESC
            LIMIT %s OFFSET %s
            """
            
            results = self.db.execute_read_dict(query, (limit, offset))
            
            # Count total images
            count_query = "SELECT COUNT(*) as total FROM steganography_images"
            count_result = self.db.execute_read_one(count_query)
            total_images = count_result[0] if count_result else 0
            
            # Add file info
            if results:
                for img in results:
                    filepath = os.path.join(self.upload_folder, img['image_path'])
                    if os.path.exists(filepath):
                        img['file_size'] = os.path.getsize(filepath)
                        img['url'] = f'/uploads/{img["image_path"]}'
                    else:
                        img['file_size'] = 0
                        img['url'] = None
            
            return {
                'success': True,
                'page': page,
                'limit': limit,
                'total': total_images,
                'total_pages': (total_images + limit - 1) // limit,
                'count': len(results) if results else 0,
                'images': results if results else []
            }
            
        except Exception as e:
            print(f"❌ Error getting public images: {str(e)}")
            import traceback
            traceback.print_exc()
            return {
                'success': False,
                'message': str(e)
            }
    
    def get_image_data(self, image_id, user_id=None):
        """
        Get image data (base64) untuk download
        
        Args:
            image_id: ID gambar
            user_id: ID user (untuk validasi ownership, optional)
            
        Returns:
            Dictionary dengan image data
        """
        try:
            query = """
            SELECT id, user_id, image_path, created_at
            FROM steganography_images
            WHERE id = %s
            """
            params = [image_id]
            
            # Jika ada user_id, validasi ownership
            if user_id:
                query += " AND user_id = %s"
                params.append(user_id)
            
            result = self.db.execute_read_dict(query, tuple(params))
            
            if not result:
                return {
                    'success': False,
                    'message': 'Gambar tidak ditemukan'
                }
            
            img = result[0]
            filepath = os.path.join(self.upload_folder, img['image_path'])
            
            if not os.path.exists(filepath):
                return {
                    'success': False,
                    'message': 'File tidak ditemukan di storage'
                }
            
            # Read file as base64
            with open(filepath, 'rb') as f:
                image_bytes = f.read()
                image_base64 = base64.b64encode(image_bytes).decode('utf-8')
            
            return {
                'success': True,
                'data': {
                    'id': img['id'],
                    'user_id': img['user_id'],
                    'filename': img['image_path'],
                    'file_size': len(image_bytes),
                    'image_data': image_base64,
                    'url': f'/uploads/{img["image_path"]}'
                }
            }
            
        except Exception as e:
            print(f"❌ Error getting image data: {str(e)}")
            return {
                'success': False,
                'message': str(e)
            }
    
    def decode_message(self, image_id, user_id=None):
        """
        Decode pesan rahasia dari gambar
        
        Args:
            image_id: ID gambar
            user_id: ID user (untuk validasi, optional)
            
        Returns:
            Dictionary dengan decoded message
        """
        try:
            # Get image data
            result = self.get_image_data(image_id, user_id)
            
            if not result['success']:
                return result
            
            image_base64 = result['data']['image_data']
            
            print(f"🔓 Decoding secret message from image {image_id}...")
            
            # Decode message
            secret_message = self.stego.decode_message(image_base64)
            
            print(f"✅ Message decoded successfully!")
            
            return {
                'success': True,
                'message': 'Pesan berhasil di-decode',
                'data': {
                    'secret_message': secret_message,
                    'message_length': len(secret_message)
                }
            }
            
        except Exception as e:
            print(f"❌ Error decoding message: {str(e)}")
            import traceback
            traceback.print_exc()
            return {
                'success': False,
                'message': f'Error: {str(e)}'
            }
    
    def delete_image(self, image_id, user_id):
        """
        Delete gambar (dari database dan filesystem)
        
        Args:
            image_id: ID gambar
            user_id: ID user (untuk validasi ownership)
            
        Returns:
            Dictionary dengan status
        """
        try:
            # Get image path
            query = """
            SELECT image_path
            FROM steganography_images
            WHERE id = %s AND user_id = %s
            """
            
            result = self.db.execute_read_dict(query, (image_id, user_id))
            
            if not result:
                return {
                    'success': False,
                    'message': 'Gambar tidak ditemukan atau bukan milik Anda'
                }
            
            image_path = result[0]['image_path']
            filepath = os.path.join(self.upload_folder, image_path)
            
            # Delete dari filesystem
            file_deleted = False
            if os.path.exists(filepath):
                os.remove(filepath)
                file_deleted = True
                print(f"🗑️ File deleted: {filepath}")
            
            # Delete dari database
            delete_query = """
            DELETE FROM steganography_images
            WHERE id = %s AND user_id = %s
            """
            
            db_deleted = self.db.execute_query(delete_query, (image_id, user_id))
            
            if db_deleted:
                return {
                    'success': True,
                    'message': 'Gambar berhasil dihapus',
                    'file_deleted': file_deleted
                }
            else:
                return {
                    'success': False,
                    'message': 'Gagal menghapus dari database'
                }
            
        except Exception as e:
            print(f"❌ Error deleting image: {str(e)}")
            return {
                'success': False,
                'message': str(e)
            }
