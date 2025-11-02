import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../superEncrypt/super_encrypt_view.dart';
import 'home_page_model.dart';

class HomePageController extends GetxController {

  // --- STATE ---
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var messages = <Message>[].obs;

  // <<< FIX 2: 'id' akan kita isi di onInit >>>
  int id = 0;

  @override
  void onInit() {
    super.onInit();

    // <<< FIX 2 (Lanjutan): Ambil 'id' dari argumen saat controller dibuat >>>
    if (Get.arguments != null && Get.arguments is Map) {
      id = Get.arguments["id"] ?? 0;
    } else {
      print("PERINGATAN: Controller tidak menerima argumen 'id'.");
    }

    // Panggil fetchMessages dengan 'id' yang sudah di-update
    fetchMessages(id);
  }

  // 1. FUNGSI UNTUK MENGAMBIL DATA PESAN
  Future<void> fetchMessages(int id) async {
    String? host = dotenv.env['API_HOST'];
    print('ID yang dipakai controller untuk fetch: $id');

    if (id == 0) {
      errorMessage('ID User tidak valid (0). Gagal mengambil data.');
      isLoading(false);
      return;
    }

    final Uri url = Uri.parse('$host/api/messages/inbox?user_id=$id&limit=5&offset=0');

    try {
      isLoading(true);
      errorMessage('');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> messagesJson = body['data']['messages'];
          messages.value = messagesJson
              .map((jsonItem) => Message.fromJson(jsonItem)) // <-- INI WAJIB
              .toList();
          // =======================================================

        } else {
          throw Exception('Format data dari server salah.');
        }
      } else {
        throw Exception('Gagal terhubung. Status: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  // Fungsi refresh akan otomatis pakai 'id' yang sudah disimpan
  void refreshMessages() {
    fetchMessages(id);
  }

  // Fungsi FAB dari Anda (tidak diubah)
  void showAddItemSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            const ListTile(
              title: Text(
                'Tambah Item Rahasia Baru',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: const Text('Buat Catatan Aman'),
              onTap: () {
                Get.back();
                Get.toNamed('/super-encrypt');
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Upload File Aman'),
              onTap: () {
                Get.back();
                Get.toNamed('/file-encrypt');
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Sembunyikan Pesan di Gambar'),
              onTap: () {
                Get.back();
                Get.toNamed('/steganography');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi Logout (tidak diubah)
  void logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Apakah Anda yakin ingin keluar?",
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.offAllNamed('/login');
      },
    );
  }
}