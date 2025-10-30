import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'login_register_view.dart';

class SignInUpController extends GetxController {
  var isLoading = false.obs;

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
      } else {
        // Gagal
        print("Gagal mengirim data. Status code: ${response.statusCode}");
        print("Pesan error: ${response.body}");
      }

    }catch(e){
      Get.snackbar('Error', 'Failed to connect to server',
          snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
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
      } else {
        // Gagal
        print("Gagal mengirim data. Status code: ${response.statusCode}");
        print("Pesan error: ${response.body}");
      }

    }catch(e){
      Get.snackbar('Error', 'Failed to connect to server',
          snackPosition: SnackPosition.BOTTOM);
      print("error : $e");
      isLoading.value = false;
      return;
    }
    isLoading.value = false;
  }
}
