import 'dart:convert'; // Diperlukan untuk jsonDecode
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SendMessageController extends GetxController {

  final String? host = dotenv.env['API_HOST']; // Ambil host dari .env

  late TextEditingController receiverController;
  late TextEditingController messageController;

  var isLoading = false.obs;
  var attachments = <File>[].obs; // List file untuk lampiran

  late int currentUserId; // ID pengirim

  @override
  void onInit() {
    super.onInit();
    receiverController = TextEditingController();
    messageController = TextEditingController();
    currentUserId = Get.arguments as int;
  }

  @override
  void onClose() {
    receiverController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> pickAttachments() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      // Optional: Filter berdasarkan tipe file yang didukung API Anda
      type: FileType.custom,
      allowedExtensions: [
        'png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp',
        'pdf', 'doc', 'docx', 'txt', 'rtf',
        'zip', 'rar', '7z',
        'mp3', 'mp4', 'avi', 'mov',
        'xlsx', 'xls', 'csv'
      ],
    );

    if (result != null) {
      for (var path in result.paths) {
        if (path != null) {
          // Cek ukuran file (Max 10MB)
          File file = File(path);
          int fileSize = await file.length();
          if (fileSize > 10 * 1024 * 1024) { // 10MB
            _showError('File ${file.path.split('/').last} terlalu besar (Max 10MB)');
          } else {
            attachments.add(file); // Tambahkan file ke list reaktif
          }
        }
      }
    }
  }

  /// 2. Menghapus file dari lampiran
  void removeAttachment(File file) {
    attachments.remove(file);
  }

  /// 3. Mengirim pesan dan lampiran dalam satu request
  Future<void> sendMessage() async {
    if (receiverController.text.isEmpty || messageController.text.isEmpty) {
      _showError('Email penerima dan pesan harus diisi');
      return;
    }

    if (currentUserId == null) {
      _showError('User ID tidak ditemukan. Buka halaman ini dari menu yang benar.');
      return;
    }

    if (host == null || host!.isEmpty) {
      _showError('Konfigurasi API_HOST kosong. Pastikan file .env sudah diisi.');
      return;
    }

    isLoading(true);

    try {
      // 1. Buat Multipart Request
      final url = Uri.parse('$host/api/messages/send');
      var request = http.MultipartRequest('POST', url);

      // Jangan set header Content-Type ke application/json di Multipart!
      // request.headers['Content-Type'] = 'multipart/form-data'; // http lib akan set otomatis

      // 2. Tambahkan field teks (sesuai 'Form-Data' di dokumentasi)
      request.fields['sender_id'] = currentUserId.toString();
      request.fields['receiver_email'] = receiverController.text;
      request.fields['message_text'] = messageController.text;

      // 3. Tambahkan file (jika ada)
      if (attachments.isNotEmpty) {
        for (var file in attachments) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'files', // 'key' untuk file (sesuai dokumentasi)
              file.path,
            ),
          );
        }
      }

      // 4. Kirim request
      var response = await request.send();

      // 5. Baca response
      final responseBody = await response.stream.bytesToString();

      // Pastikan server mengembalikan JSON; jika tidak, tampilkan raw snippet
      final contentType = response.headers['content-type'] ?? '';
      Map<String, dynamic>? result;
      try {
        if (contentType.contains('application/json')) {
          result = jsonDecode(responseBody) as Map<String, dynamic>;
        } else {
          throw const FormatException('Non-JSON response');
        }
      } catch (_) {
        // Tampilkan potongan HTML / teks untuk debugging
        final snippet = responseBody.length > 200
            ? responseBody.substring(0, 200)
            : responseBody;
        throw Exception('Server tidak mengembalikan JSON (status ${response.statusCode}).\nCuplikan respons: $snippet');
      }

      // 6. Cek hasil (Dokumentasi Anda menyebut 201, tapi bisa juga 200)
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (result['success'] == true) {
          // --- BERHASIL ---
          _showSuccess(result['message'] ?? 'Pesan berhasil dikirim');
          messageController.clear();
          receiverController.clear();
          attachments.clear(); // Kosongkan list lampiran
        } else {
          // Server merespon 200/201 tapi 'success' false
          throw Exception(result['message'] ?? 'Gagal mengirim pesan');
        }
      } else {
        // Gagal (misal: 400, 404, 500)
        throw Exception(result['message'] ?? 'Gagal mengirim. Coba cek koneksinya yah :(');
      }

    } catch (e) {
      print("Error saat mengirim pesan: $e");
      print("error decode: $e"); // Ini yang terjadi pada Anda
      _showError(e.toString());
    } finally {
      isLoading(false); // Selesai loading
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      'Error', msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _showSuccess(String msg) {
    Get.snackbar(
      'Sukses', msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}