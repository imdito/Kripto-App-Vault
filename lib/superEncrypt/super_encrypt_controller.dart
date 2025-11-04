import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:kripto_app/superEncrypt/super_encrypt_service.dart';

class SuperEncryptController extends GetxController {

  // --- KONTROLER INPUT ---
  late TextEditingController textController;
  late TextEditingController caesarController;
  late TextEditingController vigenereController;
  late TextEditingController desController;
  late TextEditingController ivController;

  // --- DEPENDENSI ---
  // Asumsi Anda sudah memiliki class service ini
  final _service = SuperEncryptService();

  // --- STATE REAKTIF ---
  var isLoading = false.obs;
  var result = "".obs; // Menggantikan _result
  var encryptedData = Rxn<Map<String, dynamic>>(); // Menggantikan _encryptedData

  // --- LIFECYCLE ---
  @override
  void onInit() {
    super.onInit();
    // Inisialisasi controller dengan nilai default dari kode asli
    textController = TextEditingController();
    caesarController = TextEditingController(text: '3');
    vigenereController = TextEditingController(text: 'KEY');
    desController = TextEditingController(text: 'secret12');
    ivController = TextEditingController(text: '12345678');
  }

  @override
  void onClose() {
    // Selalu dispose controller
    textController.dispose();
    caesarController.dispose();
    vigenereController.dispose();
    desController.dispose();
    super.onClose();
  }

  // --- LOGIKA AKSI ---

  Future<void> encrypt() async {
    try {
      isLoading(true); // Mulai loading

      final data = await _service.encrypt(
        text: textController.text,
        caesarShift: int.parse(caesarController.text),
        vigenereKey: vigenereController.text,
        desKey: desController.text,
      );

      encryptedData.value = data; // Simpan data terenkripsi
      result.value = '✅ Encrypted!\nCiphertext: ${data['ciphertext']}';

    } catch (e) {
      result.value = '❌ Error: $e';
    } finally {
      isLoading(false); // Selesai loading
    }
  }

  Future<void> decrypt() async {
    if (encryptedData.value == null) {
      result.value = '❌ No encrypted data!';
      return;
    }

    try {
      isLoading(true); // Mulai loading

      final plaintext = await _service.decrypt(
        chiperText: textController.text,
        caesarShift: int.parse(caesarController.text),
        vigenereKey: vigenereController.text,
        desKey: desController.text,
        iv: ivController.text,
      );
      result.value = '✅ Decrypted: $plaintext';

    } catch (e) {
      result.value = '❌ Error: $e';
    } finally {
      isLoading(false); // Selesai loading
    }
  }

  void copyResultToClipboard(String type) {
    String? textToCopy;
    String snackbarMessage = "";

    if(type == 'iv') {
      if (encryptedData.value != null && encryptedData.value!['iv'] != null) {
        textToCopy = encryptedData.value!['iv'];
      }
    }else{
    if (encryptedData.value != null && result.value.startsWith('✅ Encrypted!')) {
      textToCopy = encryptedData.value!['ciphertext'];
      snackbarMessage = "Ciphertext disalin ke clipboard!";
    }
    // Cek apakah hasil terakhir adalah dekripsi
    else if (result.value.startsWith('✅ Decrypted:')) {
      // Ambil teks setelah '✅ Decrypted: '
      textToCopy = result.value.replaceFirst('✅ Decrypted: ', '');
      snackbarMessage = "Plainteks disalin ke clipboard!";
    }
  }
    // Lakukan aksi copy jika ada teks
    if (textToCopy != null) {
      Clipboard.setData(ClipboardData(text: textToCopy));
      Get.snackbar(
        "Berhasil Disalin",
        snackbarMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else if (result.value.isNotEmpty) {
      // Salin apapun yang ada di box jika tidak terdeteksi
      Clipboard.setData(ClipboardData(text: result.value));
      Get.snackbar(
        "Disalin",
        "Hasil disalin ke clipboard!",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

