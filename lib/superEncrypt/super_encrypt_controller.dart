import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk Clipboard
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class SuperEncryptController extends GetxController {

  final String? baseUrl = dotenv.env['API_HOST']; // Sesuaikan jika perlu

  // --- STATE KONTROLER ---
  final textInputController = TextEditingController();
  final keyController = TextEditingController();

  // --- STATE REAKTIF (.obs) ---
  var isLoading = false.obs;
  var resultText = "".obs; // Untuk menampung hasil enkripsi/dekripsi

  @override
  void onClose() {
    textInputController.dispose();
    keyController.dispose();
    super.onClose();
  }

  // ========== ENCRYPT ==========
  Future<void> encryptText() async {
    final String inputText = textInputController.text;
    final String key = keyController.text;

    if (inputText.isEmpty || key.isEmpty) {
      _showError("Teks input dan Kunci Rahasia tidak boleh kosong.");
      return;
    }

    isLoading(true);
    resultText.value = ""; // Kosongkan hasil sebelumnya

    try {
      print('🔒 Encrypting text...');
      final response = await http.post(
        Uri.parse('$baseUrl/api/crypto/encrypt'), // Ganti dengan endpoint Anda
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': inputText,
          'key': key, // Asumsi API butuh kunci
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        resultText.value = data['data']['ciphertext']; // Sesuaikan JSON response
        _showSuccess("Teks berhasil dienkripsi!");
      } else {
        final error = jsonDecode(response.body);
        _showError(error['message']);
      }
    } catch (e) {
      _showError("Error koneksi: $e");
    } finally {
      isLoading(false);
    }
  }

  // ========== DECRYPT ==========
  Future<void> decryptText() async {
    final String inputText = textInputController.text; // Ini berisi chiperteks
    final String key = keyController.text;

    if (inputText.isEmpty || key.isEmpty) {
      _showError("Teks input dan Kunci Rahasia tidak boleh kosong.");
      return;
    }

    isLoading(true);
    resultText.value = "";

    try {
      print('🔓 Decrypting text...');
      final response = await http.post(
        Uri.parse('$baseUrl/api/crypto/decrypt'), // Ganti dengan endpoint Anda
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'ciphertext': inputText,
          'key': key,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        resultText.value = data['data']['plaintext']; // Sesuaikan JSON response
        _showSuccess("Teks berhasil didekripsi!");
      } else {
        final error = jsonDecode(response.body);
        _showError(error['message']);
      }
    } catch (e) {
      _showError("Error koneksi: $e");
    } finally {
      isLoading(false);
    }
  }

  // --- UI FEEDBACK & HELPERS ---

  void clearFields() {
    textInputController.clear();
    keyController.clear();
    resultText.value = "";
  }

  void copyToClipboard() {
    if (resultText.value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: resultText.value));
      _showSuccess("Teks hasil disalin ke clipboard!");
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      'Error', msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showSuccess(String msg) {
    Get.snackbar(
      'Sukses', msg,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}