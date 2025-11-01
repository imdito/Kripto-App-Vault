import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get_storage/get_storage.dart';
class ProfileController extends GetxController {

  final idUser = 1.obs;
  final userName = "User SecureVault".obs;
  final GetStorage _box = GetStorage();
  final userEmail = "user@email.com".obs;
  final LocalAuthentication biometricAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  String _authorizedMessage = "Not Authorized";
  var isBiometricEnabled = false.obs;
  var isBiometricSupported = false.obs;

  // --- ACTIONS ---
  void onInit() {
    super.onInit();
    checkBiometrics();
    isBiometricEnabled.value = _box.read('biometric_enabled') ?? false;;
  }

  void editProfile() {
    Get.snackbar("Fitur", "Navigasi ke halaman edit profil.");
    Get.toNamed('/edit-profile');
  }

  void changeMasterPin() {
    Get.snackbar("Keamanan", "Navigasi ke halaman ubah PIN.");
    // Get.toNamed('/change-pin');
  }

  Future<void> toggleBiometric(bool newValue) async {
    if (newValue == true) {
      // Jika pengguna MENCOBA MENGAKTIFKAN
      bool authenticated = await _authenticate(
          "Verifikasi identitas Anda untuk mengaktifkan biometrik di SecureVault"
      );

      if (authenticated) {
        // Jika verifikasi berhasil
        _box.write('biometric_enabled', true);
        isBiometricEnabled(true);
        Get.snackbar(
          "Berhasil",
          "Login biometrik telah diaktifkan.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // Jika verifikasi gagal (dibatalkan, salah, dll)
        isBiometricEnabled(false); // Balikkan switch ke posisi off
      }
    } else {
      // Jika pengguna MENCOBA MENONAKTIFKAN
      _box.write('biometric_enabled', false);
      isBiometricEnabled(false);
      Get.snackbar(
        "Dinonaktifkan",
        "Login biometrik telah dinonaktifkan.",
      );
    }
  }


  Future<bool> _authenticate(String reason) async {
    if (!isBiometricSupported.value) {
      Get.snackbar("Error", "Perangkat Anda tidak mendukung biometrik.");
      return false;
    }

    try {
      return await biometricAuth.authenticate(
        localizedReason: reason,
          biometricOnly: true, // Hanya izinkan biometrik (bukan PIN perangkat)

      );
    } on PlatformException catch (e) {
      String message = "Terjadi kesalahan tidak diketahui.";
      if (e.code == 'NotEnrolled') {
        message = "Anda belum mendaftarkan biometrik di perangkat ini.";
      } else if (e.code == 'NotAvailable') {
        message = "Biometrik tidak tersedia di perangkat ini.";
      } else if (e.code == 'PasscodeNotSet') {
        message = "Anda harus mengatur PIN/Pola/Password terlebih dahulu.";
      }
      Get.snackbar(
        "Otentikasi Gagal",
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
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

  Future<void> checkBiometrics() async {
    try {
      isBiometricSupported.value = await biometricAuth.canCheckBiometrics;
    } catch (e) {
      isBiometricSupported.value = false;
      print("Error cek biometrik: $e");
    }
  }

  Future<void> authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await biometricAuth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
      );
      _authorizedMessage = authenticated ? 'Authorized' : 'Not Authorized';
    } on PlatformException catch (e) {
      print(e);
    }
  }

}