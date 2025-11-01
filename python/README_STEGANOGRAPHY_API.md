# Steganography API Documentation

API untuk menyembunyikan pesan dalam gambar menggunakan LSB Steganography dan menyimpannya ke local storage (folder `uploads/`).

## Setup

### 1. Run Database Migration (Optional)

```sql
mysql -u root -p
USE berangkas;

-- Buat table jika belum ada
CREATE TABLE IF NOT EXISTS steganography_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    image_path VARCHAR(500) NOT NULL COMMENT 'Filename di folder uploads/',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### 2. Install Dependencies

```bash
cd python
pip install -r requirements.txt
```

Dependencies yang dibutuhkan:
- `Pillow` - Untuk manipulasi gambar
- `Flask` - Web framework
- `mysql-connector-python` - Database connector

### 3. Run Server

```bash
python main.py
```

Folder `uploads/` akan dibuat otomatis saat pertama kali run.

## Endpoints

### 1. Upload & Process Image (Steganography)
**POST** `/api/stego/upload`

Encode pesan rahasia ke dalam gambar, lalu simpan ke local storage (folder `uploads/`).

**Flow:**
1. Encode secret message ke gambar (LSB Steganography)
2. Save gambar ke folder `uploads/`
3. Save metadata (user_id, filename) ke database

**Request Body:**
```json
{
  "user_id": 1,
  "image_data": "base64_encoded_original_image",
  "secret_message": "Ini adalah pesan rahasia",
  "filename": "my_secret.png"  // optional
}
```

**Response Success (201):**
```json
{
  "success": true,
  "message": "Gambar berhasil diproses dan disimpan",
  "data": {
    "id": 1,
    "user_id": 1,
    "filename": "1_20251031_120000_abc123.png",
    "original_filename": "my_secret.png",
    "filepath": "uploads/1_20251031_120000_abc123.png",
    "file_size": 524288,
    "message_length": 25,
    "image_capacity": 50000,
    "url": "/uploads/1_20251031_120000_abc123.png"
  }
}
```

**Response Error (400):**
```json
{
  "success": false,
  "message": "Pesan terlalu panjang! Maksimal 50000 karakter, pesan kamu 60000 karakter"
}
```

**Akses Gambar:**
```
http://localhost:5000/uploads/1_20251031_120000_abc123.png
```

---

### 2. Public Gallery (Semua Gambar)
**GET** `/api/stego/gallery?page=1&limit=20`

Get semua gambar dari semua user (Public Gallery dengan pagination).

**Konsep:** Semua user bisa lihat gambar orang lain, tapi hanya bisa decode message jika tau password/key.

**Query Parameters:**
- `page` (optional, default=1): Halaman
- `limit` (optional, default=20, max=100): Jumlah per halaman

**Example:**
```
GET /api/stego/gallery
GET /api/stego/gallery?page=2&limit=10
```

**Response Success (200):**
```json
{
  "success": true,
  "page": 1,
  "limit": 20,
  "total": 45,
  "total_pages": 3,
  "count": 20,
  "images": [
    {
      "id": 3,
      "user_id": 2,
      "username": "john_doe",
      "created_at": "2025-10-31 15:00:00",
      "image_path": "2_20251031_150000_xyz789.png",
      "file_size": 524288,
      "url": "/uploads/2_20251031_150000_xyz789.png"
    },
    {
      "id": 2,
      "user_id": 1,
      "username": "alice",
      "created_at": "2025-10-31 14:30:00",
      "image_path": "1_20251031_143000_abc123.png",
      "file_size": 1048576,
      "url": "/uploads/1_20251031_143000_abc123.png"
    }
  ]
}
```

---

### 3. List User Images
**GET** `/api/stego/images/<user_id>`

Get semua gambar steganografi milik user tertentu (My Images).

**Example:**
```
GET /api/stego/images/1
```

**Response Success (200):**
```json
{
  "success": true,
  "count": 2,
  "images": [
    {
      "id": 2,
      "user_id": 1,
      "image_path": "1_20251031_143000_xyz789.png",
      "file_size": 1048576,
      "url": "/uploads/1_20251031_143000_xyz789.png",
      "created_at": "2025-10-31 14:30:00"
    },
    {
      "id": 1,
      "user_id": 1,
      "image_path": "1_20251031_120000_abc123.png",
      "file_size": 786432,
      "url": "/uploads/1_20251031_120000_abc123.png",
      "created_at": "2025-10-31 12:00:00"
    }
  ]
}
```

---

### 4. Get Image Info
**GET** `/api/stego/image/<image_id>?user_id=<user_id>`

Get metadata gambar dan data lengkapnya.

**Example:**
```
GET /api/stego/image/1?user_id=1
```

**Response Success (200):**
```json
{
  "success": true,
  "image": {
    "id": 1,
    "user_id": 1,
    "image_path": "1_20251031_120000_abc123.png",
    "file_size": 524288,
    "url": "/uploads/1_20251031_120000_abc123.png",
    "created_at": "2025-10-31 12:00:00",
    "image_data": "iVBORw0KGgoAAAANSUhEUgAA..." 
  }
}
```

**Catatan:** 
- Field `image_data` berisi base64 encoded image untuk langsung ditampilkan di Flutter
- Field `url` bisa digunakan untuk akses langsung: `http://localhost:5000/uploads/1_20251031_120000_abc123.png`

---

### 5. Decode Secret Message
**GET** `/api/stego/decode/<image_id>?user_id=<user_id>`

Load gambar dari local storage dan decode pesan rahasianya.

**Example:**
```
GET /api/stego/decode/1?user_id=1
```
```
GET /api/stego/decode/1?user_id=1
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Pesan berhasil di-decode",
  "data": {
    "secret_message": "Ini adalah pesan rahasia",
    "message_length": 25
  }
}
```

**Response Error (404):**
```json
{
  "success": false,
  "message": "Gambar tidak ditemukan atau bukan milik Anda"
}
```

---

### 6. Delete Image
**DELETE** `/api/stego/image/<image_id>`

Hapus gambar dari database dan filesystem (folder uploads/).

**Request Body:**
```json
{
  "user_id": 1
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Gambar berhasil dihapus dari database dan filesystem"
}
```

---

## Testing dengan Postman

### 1. Upload Image with Secret Message

**Setup:**
- Method: POST
- URL: `http://localhost:5000/api/stego/upload`
- Headers: `Content-Type: application/json`

**Body (raw JSON):**
```json
{
  "user_id": 1,
  "image_data": "/9j/4AAQSkZJRgABAQEAYABgAAD...",
  "secret_message": "Rahasia banget nih!",
  "filename": "secret_photo.png"
}
```

**Tips:** 
- Convert image ke base64: https://www.base64-image.de/
- Atau pakai Python: `base64.b64encode(open('image.png', 'rb').read()).decode()`

### 2. Public Gallery

**Setup:**
- Method: GET
- URL: `http://localhost:5000/api/stego/gallery?page=1&limit=20`

### 3. List My Images

**Setup:**
- Method: GET
- URL: `http://localhost:5000/api/stego/images/1`

### 4. Get Image Info

**Setup:**
- Method: GET
- URL: `http://localhost:5000/api/stego/image/1?user_id=1`

### 5. Decode Message

**Setup:**
- Method: GET
- URL: `http://localhost:5000/api/stego/decode/1?user_id=1`

### 6. Delete Image

**Setup:**
- Method: DELETE
- URL: `http://localhost:5000/api/stego/image/1`
- Body (raw JSON):
```json
{
  "user_id": 1
}
```

---

## How It Works

### LSB Steganography Algorithm

1. **Encoding:**
   - Pesan diubah ke binary (8 bits per karakter)
   - Setiap bit pesan disimpan di LSB (Least Significant Bit) dari pixel RGB
   - Delimiter `###END###` ditambahkan di akhir pesan
   - Gambar disimpan dalam format PNG (lossless)

2. **Decoding:**
   - Ambil LSB dari setiap pixel RGB
   - Gabungkan bits menjadi bytes
   - Convert bytes ke text sampai ketemu delimiter

### Storage Flow

```
User Upload
    ↓
[Encode Message → Image] (LSB Steganography)
    ↓
[Save to Local Storage] (uploads/ folder, PNG format)
    ↓
[Save Metadata to DB] (user_id, image_path, file_size)
    ↓
Done ✅
```

### Retrieval Flow

```
User Request Decode
    ↓
[Get image_path from DB]
    ↓
[Load Image from uploads/ folder]
    ↓
[Decode Message] (Extract LSB)
    ↓
Return Secret Message ✅
```

---

## Database Schema

### Table: steganography_images

| Column | Type | Description |
|--------|------|-------------|
| id | INT AUTO_INCREMENT | Primary key |
| user_id | INT | Foreign key ke users table |
| image_path | VARCHAR(500) | Nama file di folder uploads/ |
| created_at | TIMESTAMP | Waktu upload |

---

## Security & Limitations

### Security Considerations

✅ **Good:**
- Pesan tersembunyi tidak terlihat kasat mata
- File disimpan di local server (kontrol penuh)
- User validation (hanya owner yang bisa decode)
- Tidak perlu konfigurasi cloud storage

⚠️ **Limitations:**
- Steganography bukan enkripsi! Pesan masih plaintext di dalam gambar
- Jika ada yang tahu pakai LSB, pesan bisa di-extract
- Compression (JPEG) akan rusak data steganografi (harus PNG)

### Recommendations for Production

1. **Encrypt message before hiding:**
   ```python
   # Tambahkan enkripsi AES/RSA sebelum steganography
   encrypted_message = encrypt_aes(secret_message, key)
   encoded_image = stego.encode_message(image, encrypted_message)
   ```

2. **Add authentication:**
   - Use JWT tokens
   - Validate user ownership
   - Rate limiting

3. **Add file size limits:**
   - Max image size: 10 MB
   - Max message length: 10,000 chars

4. **Add audit logs:**
   - Track who accessed what
   - Log encode/decode activities

---

## Capacity Calculation

**Formula:**
```
Max Characters = (Width × Height × 3) / 8 - len(delimiter)
```

**Example:**
- Image: 1920×1080 pixels
- Total pixels: 2,073,600
- RGB channels: 2,073,600 × 3 = 6,220,800 bits
- Max characters: 6,220,800 / 8 = 777,600 chars
- Minus delimiter (9 chars) = **777,591 characters**

**Tips:**
- Pakai gambar besar untuk pesan panjang
- 1 megapixel ≈ 375,000 characters capacity
- Cek capacity dengan `/api/stego/capacity` (bisa ditambahkan)

---

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| "Pesan terlalu panjang" | Message > image capacity | Use larger image or shorter message |
| "Gambar tidak ditemukan" | Invalid image_id or user_id | Check ID and ownership |
| "Gagal menyimpan gambar" | Filesystem/permission error | Check uploads/ folder permissions |
| "Error decoding message" | Image bukan steganography | Make sure image was encoded first |
| "User tidak ditemukan" | Invalid user_id | Check user exists in database |

---

## Next Steps - Flutter Integration

```dart
// Upload image with secret message
Future<void> uploadStegoImage(File imageFile, String secretMessage) async {
  // Convert image to base64
  final bytes = await imageFile.readAsBytes();
  final base64Image = base64Encode(bytes);
  
  final response = await http.post(
    Uri.parse('$apiHost/api/stego/upload'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user_id': currentUserId,
      'image_data': base64Image,
      'secret_message': secretMessage,
      'filename': 'my_secret.png'
    }),
  );
  
  if (response.statusCode == 201) {
    print('Upload success!');
  }
}

// Decode secret message
Future<String> decodeMessage(int imageId) async {
  final response = await http.get(
    Uri.parse('$apiHost/api/stego/decode/$imageId?user_id=$currentUserId'),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['data']['secret_message'];
  }
  return '';
}

// Display image from local storage
Widget buildStegoImage(String imageUrl) {
  // Untuk emulator Android gunakan 10.0.2.2 instead of localhost
  final url = imageUrl.replaceAll('localhost', '10.0.2.2');
  
  return Image.network(
    'http://10.0.2.2:5000$url', // contoh: http://10.0.2.2:5000/uploads/1_20251031_120000_abc123.png
    fit: BoxFit.cover,
  );
}
```
