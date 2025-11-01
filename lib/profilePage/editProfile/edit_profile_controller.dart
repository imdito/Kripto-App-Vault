import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../profile_controller.dart';
import 'package:get/get.dart';


class EditProfileController extends GetxController {
  
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController passwordController;
  late TextEditingController oldPasswordController;
  var isLoading = false.obs;

  // Kita akan mengambil data dari ProfileController yang sudah ada di memori
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void onInit() {
    super.onInit();
    // Isi form dengan data yang ada saat ini
    passwordController = TextEditingController(text: "");
    oldPasswordController = TextEditingController(text: "");
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }

  // --- ACTIONS ---
  // Fungsi untuk menyimpan perubahan
  Future<void> saveChanges() async {
    // 1. Validasi form
    if (!formKey.currentState!.validate()) {
      return; // Jika tidak valid, hentikan
    }

    try {
      isLoading(true);
      // 2. Simulasi proses penyimpanan ke server (API call)
      await Future.delayed(const Duration(seconds: 2));
      // Di sini Anda akan menambahkan logika untuk mengirim data ke server
      changePassword(profileController.idUser.value, passwordController.text, oldPasswordController.text);
    
      // 4. Kembali ke halaman profil
      Get.back();

      // 5. Beri notifikasi sukses
      Get.snackbar(
        "Berhasil",
        "Profil Anda telah diperbarui.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      // Jika gagal, tampilkan error
      Get.snackbar(
        "Gagal",
        "Terjadi kesalahan saat menyimpan profil: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> changePassword(int id,String password, String old_password) async {
    isLoading.value = true;
    String? host= dotenv.env['API_HOST'];
    print('API Host: $host');
    final url = Uri.parse('$host/api/change-password');
    try{
      final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode( {
            'id': id,
            'new_password': password,
            'old_password': old_password,
          }));

      // 4. Cek status kode balasan
      if (response.statusCode == 200) {
        // Sukses
        print("Data berhasil dikirim!");
        // Decode balasan JSON dari server
        final responseData = jsonDecode(response.body);
        print("Respon server: ${responseData['message']}");

        Get.snackbar(
          'Selamat',
          'Password Anda berhasil diubah!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Gagal
        print("Gagal mengirim data. Status code: ${response.statusCode}");
        print("Pesan error: ${response.body}");

        final responseData = jsonDecode(response.body);
        Get.snackbar(
          'Gagal',
          responseData['message'] ?? 'password salah',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

    }catch(e){
      Get.snackbar(
        'Error',
        'Failed to connect to server',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
      return;
    }
    isLoading.value = false;
  }
  
}