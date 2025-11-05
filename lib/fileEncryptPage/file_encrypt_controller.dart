import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileEncryptController extends GetxController {

  // --- KONTROLER & KONSTANTA ---
  late TextEditingController passwordController;
  final String? baseUrl = dotenv.env['API_HOST'] ?? '';

  // --- STATE REAKTIF (.obs) ---
  var status = 'Pilih file untuk dienkripsi atau dekripsi'.obs;
  var selectedFile = Rxn<File>();
  var selectedFileName = "".obs; // Helper untuk menyimpan nama file
  var isLoading = false.obs;

  // --- LIFECYCLE ---
  @override
  void onInit() {
    super.onInit();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }

  // --- LOGIKA AKSI ---

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // allow all file types
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      selectedFile.value = File(result.files.single.path!);
      selectedFileName.value = result.files.single.name;
      status.value = 'Terpilih: ${selectedFileName.value}';
    }
  }

  Future<void> encryptFile() async {
    if (selectedFile.value == null) {
      _showError('Silakan pilih file terlebih dahulu');
      return;
    }
    if (passwordController.text.isEmpty) {
      _showError('Silakan masukkan password');
      return;
    }

    isLoading(true);
    status.value = 'Enkripsi...';

    try {
      final bytes = await selectedFile.value!.readAsBytes();
      final base64File = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$baseUrl/api/file/encrypt'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'file_data': base64File,
          'password': passwordController.text,
          'filename': selectedFileName.value,
        }),
      );

      final result = jsonDecode(response.body);

      if (result['success']) {
        final encryptedBase64 = result['data']['encrypted_file'];
        final newFilename = result['data']['filename'];

        final encryptedFile = await _saveFile(encryptedBase64, newFilename);

        status.value = '✅ Enkripsi berhasil!\n📁 ${encryptedFile.path}';
        selectedFile.value = encryptedFile; // Update file terpilih ke file baru
        selectedFileName.value = newFilename; // Update nama file
        _showSuccess('File berhasil dienkripsi!');
      } else {
        _showError(result['message']);
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> decryptFile() async {
    if (selectedFile.value == null) {
      _showError('Silakan pilih file terenkripsi');
      return;
    }
    if (passwordController.text.isEmpty) {
      _showError('Silakan masukkan password');
      return;
    }

    isLoading(true);
    status.value = 'Dekripsi...';

    try {
      final bytes = await selectedFile.value!.readAsBytes();
      final base64File = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('$baseUrl/api/file/decrypt'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'file_data': base64File,
          'password': passwordController.text,
          'filename': selectedFileName.value,
        }),
      );

      final result = jsonDecode(response.body);

      if (result['success']) {
        final decryptedBase64 = result['data']['decrypted_file'];
        final newFilename = "decrypted_${result['data']['filename']}";

        final decryptedFile = await _saveFile(decryptedBase64, newFilename);

        status.value = '✅ Dekripsi berhasil!\n📁 ${decryptedFile.path}';
        selectedFile.value = decryptedFile; // Update file terpilih
        selectedFileName.value = newFilename; // Update nama
        _showSuccess('File berhasil didekripsi!');
      } else {
        if (result['error_type'] == 'WRONG_PASSWORD') {
          _showError('❌ Password Salah!');
        } else {
          _showError(result['message']);
        }
      }
    } catch (e) {
      print('e decrypt: $e');
      _showError('Error: $e');
    } finally {
      isLoading(false);
    }
  }

  // --- HELPER INTERNAL ---

  Future<File> _saveFile(String base64Data, String filename) async {
    final bytes = base64Decode(base64Data);

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

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
    status.value = message;
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Sukses',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}