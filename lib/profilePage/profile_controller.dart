import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {

  // --- STATE ---
  // Data user (bisa didapat dari service/storage lain)
  final idUser = 1.obs;
  final userName = "User SecureVault".obs;
  final userEmail = "user@email.com".obs;

  // --- ACTIONS ---

  void editProfile() {
    Get.snackbar("Fitur", "Navigasi ke halaman edit profil.");
    Get.toNamed('/edit-profile');
  }

  void changeMasterPin() {
    Get.snackbar("Keamanan", "Navigasi ke halaman ubah PIN.");
    // Get.toNamed('/change-pin');
  }

  void addBiometric() {
    // Di sinilah Anda akan memanggil package seperti 'local_auth'
    // untuk memulai proses pendaftaran biometrik perangkat.

    Get.snackbar(
      "Biometrik  fingerprint",
      "Memulai pendaftaran biometrik... (fitur segera hadir)",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToNotifications() {
    Get.snackbar("Fitur", "Navigasi ke pengaturan notifikasi.");
  }

  void logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Apakah Anda yakin ingin keluar dari SecureVault?",
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Lakukan proses clear session/token
        Get.offAllNamed('/login'); // Kembali ke login
      },
    );
  }
}