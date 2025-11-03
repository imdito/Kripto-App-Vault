import 'dart:convert';
import 'dart:io';
import 'dart:typed_data'; // Untuk Uint8List
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:file_saver/file_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'detail_message_model.dart'; // <-- Package yang direkomendasikan

class DetailMessageController extends GetxController {

  // --- STATE ---
  var isLoading = true.obs;
  var isDownloading = false.obs; // Mencegah double-tap download
  var errorMessage = ''.obs;
  var message = Rxn<MessageDetail>(); // Data pesan reaktif

  // --- DATA ---
  late int _messageId;
  late int _userId; // ID user yang sedang login
  final String? host = dotenv.env['API_HOST'];

  // --- LIFECYCLE ---
  @override
  void onInit() {
    super.onInit();

    // Ambil argumen
    if (Get.arguments != null && Get.arguments is Map) {
      _messageId = Get.arguments['messageId'];
      _userId = Get.arguments['userId']; // Simpan ID user
      fetchMessageDetail();
    } else {
      errorMessage('ID Pesan atau ID User tidak ditemukan.');
      isLoading(false);
    }
  }

  // --- LOGIKA API (FETCH) ---
  Future<void> fetchMessageDetail() async {
    try {
      isLoading(true);
      errorMessage('');

      final Uri url = Uri.parse(
          '$host/api/messages/$_messageId?user_id=$_userId'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true && body['data'] != null) {
          message.value = MessageDetail.fromJson(body['data']);
        } else {
          throw Exception(body['message'] ?? 'Format data salah');
        }
      } else {
        throw Exception('Gagal memuat detail. Status: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> downloadAttachment(Attachment attachment) async {
    if (attachment.fileSize > 10 * 1024 * 1024) {
      _showError('File terlalu besar (> 10MB). Download dibatalkan.');
      return;
    }

    isDownloading(true);
    print("--- [DEBUG] Mulai proses download... ---"); // DEBUG

    try {
      final Uri url = Uri.parse(
          '$host${attachment.downloadUrl}?user_id=$_userId'
      );

      print("[DEBUG] Memanggil URL: $url"); // DEBUG

      final response = await http.get(url, headers: {'Accept': 'application/octet-stream'});


      if (response.statusCode == 200) {
        print("[DEBUG] Download sukses. Ukuran file: ${response.bodyBytes.length} bytes."); // DEBUG
        final bytes = response.bodyBytes;
        final newFilename = attachment.filename;

        final savedFile =  await _saveFile(bytes, newFilename);


        if (savedFile != null) {
          _showSuccess('File disimpan di : ${savedFile.path}');
        } else {
          _showError('Penyimpanan dibatalkan oleh pengguna.');
        }
      } else {
        // ... (Error handling) ...
        String errorMessage = 'Gagal download. Status: ${response.statusCode}';
        try {
          final body = json.decode(response.body);
          if (body['message'] != null) {
            errorMessage = body['message'];
          }
        } catch (e) { /* Biarkan */ }

        print("[DEBUG] ERROR HTTP: $errorMessage"); // DEBUG
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("[DEBUG] CATCH BLOCK ERROR: $e"); // DEBUG
      _showError(e.toString());
    } finally {
      print("--- [DEBUG] Selesai. Set isDownloading(false) ---"); // DEBUG
      isDownloading(false);
    }
  }

  // Helper format ukuran file
  String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  // Helper Feedback
  void _showError(String msg) {
    Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red, colorText: Colors.white);
  }
  void _showSuccess(String msg) {
    Get.snackbar('Sukses', msg, snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  Future<File> _saveFile(Uint8List bytes, String filename) async {

// Prefer user's Downloads directory when available, fallback to app docs.
    Directory directory;
    try {
      if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        final maybeDownloads = await getDownloadsDirectory();
        directory = maybeDownloads ?? await getApplicationDocumentsDirectory();
      } else if (Platform.isAndroid) {
        final dl = Directory('/storage/emulated/0/Download');
        directory = await dl.exists() ? dl : await getApplicationDocumentsDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
    } catch (_) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

}
