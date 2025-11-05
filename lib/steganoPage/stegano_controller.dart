import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:saver_gallery/saver_gallery.dart';

class SteganographyController extends GetxController {
  // --- KONSTANTA ---
  String? baseUrl= dotenv.env['API_HOST'];
  final ImagePicker _picker = ImagePicker();

  // --- STATE REAKTIF (.obs) ---
  var selectedImage = Rxn<File>(); // Rxn<File>() artinya File? yang reaktif
  var isLoading = false.obs;

  // Gunakan TextEditingController untuk input, ini lebih efisien
  final messageController = TextEditingController();

  @override
  void onClose() {
    // Selalu dispose controller
    messageController.dispose();
    super.onClose();
  }

  // --- LOGIKA UTAMA (PINDAHAN DARI STATE) ---

  // ========== ENCODE ==========
  Future<void> encodeMessage() async {
    if (selectedImage.value == null || messageController.text.isEmpty) {
      _showError('Pilih gambar dan isi pesan terlebih dahulu');
      return;
    }

    if (baseUrl == null || baseUrl!.isEmpty) {
      _showError('API_HOST tidak terkonfigurasi. Pastikan .env berisi API_HOST.');
      return;
    }

    isLoading(true); // Ganti setState

    try {
      // 1. Convert image to base64
      final bytes = await selectedImage.value!.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('📤 Encoding message into image...');

      // 2. Send to API
      final uri = Uri.parse('$baseUrl/api/stego/encode');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'image_data': base64Image,
              'secret_message': messageController.text, // Ambil dari controller
            }),
          )
          .timeout(const Duration(seconds: 30));

      final contentType = response.headers['content-type'] ?? '';
      print('encode status=${response.statusCode} content-type=$contentType');

      if (response.statusCode == 200 && contentType.contains('application/json')) {
        final data = jsonDecode(response.body);
        final encodedImageBase64 = data['data']?['encoded_image'] as String?;
        if (encodedImageBase64 == null || encodedImageBase64.isEmpty) {
          _showError('Response tidak mengandung encoded_image');
          return;
        }

        // 3. Save encoded image to device
        await _saveEncodedImage(encodedImageBase64);
        _showSuccess('Gambar berhasil di-encode dan disimpan!');
      } else {
        // Coba parse JSON error jika memungkinkan
        String message;
        if (contentType.contains('application/json')) {
          try {
            final err = jsonDecode(response.body);
            message = (err['message'] ?? err['error'] ?? 'Terjadi kesalahan').toString();
          } catch (_) {
            message = 'Gagal memproses respons dari server (status ${response.statusCode})';
          }
        } else {
          // Non-JSON (misal HTML error page)
          final snippet = response.body.length > 200
              ? response.body.substring(0, 200)
              : response.body;
          message = 'Server mengembalikan non-JSON (status ${response.statusCode}).\n$snippet';
        }
        _showError(message);
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      isLoading(false); // Ganti setState
    }
  }

  // ========== DECODE ==========
  Future<void> decodeMessage() async {
    if (selectedImage.value == null) {
      _showError('Pilih gambar steganografi terlebih dahulu');
      return;
    }

    if (baseUrl == null || baseUrl!.isEmpty) {
      _showError('API_HOST tidak terkonfigurasi. Pastikan .env berisi API_HOST.');
      return;
    }

    isLoading(true); // Ganti setState

    try {
      // 1. Convert image to base64
      final bytes = await selectedImage.value!.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('🔓 Decoding message from image...');

      // 2. Send to API
      final uri = Uri.parse('$baseUrl/api/stego/decode');
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'image_data': base64Image,
            }),
          )
          .timeout(const Duration(seconds: 30));

      final contentType = response.headers['content-type'] ?? '';
      print('decode status=${response.statusCode} content-type=$contentType');

      if (response.statusCode == 200 && contentType.contains('application/json')) {
        final data = jsonDecode(response.body);
        final decodedMessage = data['data']?['secret_message']?.toString();

        if (decodedMessage == null || decodedMessage.isEmpty) {
          _showError('Tidak ada pesan rahasia ditemukan atau format respons tidak sesuai.');
          return;
        }

        // 3. Show message
        _showDialog('Pesan Rahasia Ditemukan!', decodedMessage);
      } else {
        // Tangani error non-JSON agar tidak FormatException
        String message;
        if (contentType.contains('application/json')) {
          try {
            final err = jsonDecode(response.body);
            message = (err['message'] ?? err['error'] ?? 'Terjadi kesalahan').toString();
          } catch (_) {
            message = 'Gagal memproses respons dari server (status ${response.statusCode})';
          }
        } else {
          final snippet = response.body.length > 200
              ? response.body.substring(0, 200)
              : response.body;
          message = 'Server mengembalikan non-JSON (status ${response.statusCode}).\n$snippet';
        }
        _showError(message);
      }
    } catch (e) {
      print("error decode: $e");
      _showError('Error: $e');
    } finally {
      isLoading(false); // Ganti setState
    }
  }

  // ========== HELPER ==========

  // Pick image from gallery
  Future<void> pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100, // IMPORTANT: No compression!
    );

    if (image != null) {
      selectedImage.value = File(image.path); // Ganti setState
    }
  }

  // Save base64 image to device storage
  Future<void> _saveEncodedImage(String base64Image) async {
    try {
      // Decode base64 to bytes
      final bytes = base64Decode(base64Image);


      // Save to Gallery (visible to user!)
      try {
        await SaverGallery.saveImage(
          Uint8List.fromList(bytes),
          quality: 60,
          fileName: 'stego_${DateTime.now().millisecondsSinceEpoch}.png',
          androidRelativePath: "Pictures/appName/images",
          skipIfExists: false,
        );

        // if (result['isSuccess']) {
        //   print('✅ Saved to Gallery: ${result['filePath']}');
        //   // Android: /storage/emulated/0/Pictures/stego_xxx.png
        //   // iOS: Photo Library
        //
        //   _showDialog('Success', 'Gambar berhasil disimpan ke Gallery!\nBisa dilihat di Photos/Gallery app.');
        // } else {
        //   throw Exception('Failed to save image');
        // }
      }catch(e){
        print('Error saving image to gallery: $e');
        _showError('Gagal menyimpan gambar ke Gallery: $e');
        return;
      }


    } catch (e) {
      print('❌ Error saving image: $e');
      _showError('Gagal menyimpan gambar: $e');
    }
  }

  // --- UI FEEDBACK (Ganti dengan GetX) ---

  void _showError(String msg) {
    Get.snackbar(
      'Error',
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showSuccess(String msg) {
    Get.snackbar(
      'Sukses',
      msg,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: SelectableText(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Ganti Navigator.pop
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}