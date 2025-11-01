import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../routes.dart';

class SignInUpController extends GetxController {
  var isLoading = false.obs;
  final LocalAuthentication _localAuth = LocalAuthentication();
  final GetStorage _box = GetStorage();
  var isBiometricAvailable = false.obs; // Status apakah tombol bio ditampilkan

  // 1. Cek dari GetStorage apakah biometrik pernah diaktifkan
  Future<void> checkBiometricStatus() async {
    final bool biometricEnabled = _box.read('biometric_enabled') ?? false;
    bool hardwareSupported = false;

    try {
      hardwareSupported = await _localAuth.canCheckBiometrics;
    } catch (e) {
      hardwareSupported = false;
    }

    // Hanya tampilkan tombol jika diaktifkan DI APP & didukung DI PERANGKAT
    isBiometricAvailable.value = biometricEnabled && hardwareSupported;
  }

  // 2. Fungsi yang dipanggil saat tombol biometrik ditekan
  Future<bool> loginWithBiometrics() async {
    bool authenticated = await _authenticate("Login ke SecureVault");

    if (authenticated) {
      // Jika sukses, langsung bypass login dan masuk ke home
      return true;
    } else {
      Get.snackbar(
        "Gagal",
        "Otentikasi biometrik gagal. Silakan coba lagi.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }


  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    String? host= dotenv.env['API_HOST'];
    print('API Host: $host');
    final url = Uri.parse('$host/api/login');
    try{
     final response = await http.post(
         url,
         headers: {
            'Content-Type': 'application/json; charset=UTF-8',
         },
         body: jsonEncode( {
        'email': email,
        'password': password,
      }));

      // 4. Cek status kode balasan
      if (response.statusCode == 200) {
        // Sukses
        print("Data berhasil dikirim!");
        // Decode balasan JSON dari server
        final responseData = jsonDecode(response.body);
        print("Respon server: ${responseData['message']}");
        final id = responseData['user']['id'];
        print("user id: $id");
        // Navigate to home page
        await checkBiometricStatus(); // Cek status biometrik sebelum masuk
        if(isBiometricAvailable.value){
          // Jika biometrik diaktifkan, minta otentikasi
          bool bioLoginSuccess = await loginWithBiometrics();
          if(!bioLoginSuccess){
            isLoading.value = false;
            return; // Batalkan login jika otentikasi gagal
          }
        }
        Get.offAllNamed(AppRoutes.home, arguments: {
          "id": id,
          "email": email,
          "username": responseData['user']['username'],
        });

        Get.snackbar(
          'Login Berhasil',
          'Selamat datang!',
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
          'Login Gagal',
          responseData['message'] ?? 'Email atau password salah',
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
      print("errior : $e");
      return;
    }
    isLoading.value = false;
  }

  Future<void> signUp(String email, String username, String password, String confirmPassword) async {

    isLoading.value = true;
    if(password != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match',
          snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
      return;
    }
    String? host= dotenv.env['API_HOST'];
    print('API Host: $host');
    final url = Uri.parse('$host/api/register');
    try{
      // Encode body as JSON since content-type is application/json
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      // 4. Cek status kode balasan
      if (response.statusCode == 200) {
        // Sukses
        print("Data berhasil dikirim!");
        // Decode balasan JSON dari server
        final responseData = jsonDecode(response.body);
        print("Respon server: ${responseData['message']}");

        // Navigate to home page
        Get.offAllNamed(AppRoutes.home);

        Get.snackbar(
          'Registrasi Berhasil',
          'Akun Anda berhasil dibuat!',
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
          'Registrasi Gagal',
          responseData['message'] ?? 'Terjadi kesalahan, coba lagi',
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
      print("error : $e");
      isLoading.value = false;
      return;
    }
    isLoading.value = false;
  }

  Future<bool> _authenticate(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
          biometricOnly: true,
      );
    } on PlatformException catch (e) {
      String message = "Terjadi kesalahan tidak diketahui.";
      if (e.code == 'NotEnrolled') {
        message = "Anda belum mendaftarkan biometrik di perangkat ini.";
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

}
