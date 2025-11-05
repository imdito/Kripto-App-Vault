import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'history_model.dart';

class HistoryController extends GetxController {

  // --- STATE ---
  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var sentMessages = <SentMessage>[].obs; // List reaktif untuk pesan

  // --- DATA ---
  late int currentUserId; // ID user dari halaman sebelumnya
  final String? host = dotenv.env['API_HOST'];

  // --- LIFECYCLE ---
  @override
  void onInit() {
    super.onInit();

    // Ambil 'id' yang dikirim dari HomePageController
    // Pastikan Anda menavigasi seperti ini: Get.toNamed('/sent-messages', arguments: id);
    if (Get.arguments != null) {
      currentUserId = Get.arguments as int;
      fetchSentMessages(); // Panggil API
    } else {
      errorMessage('ID User tidak ditemukan.');
      isLoading(false);
    }
  }

  // --- LOGIKA API ---
  Future<void> fetchSentMessages() async {
    try {
      isLoading(true);
      errorMessage('');

      final Uri url = Uri.parse(
          '$host/api/messages/sent?user_id=$currentUserId&limit=50&offset=0'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> messagesJson = body['data']['messages'];

          sentMessages.value = messagesJson
              .map((json) => SentMessage.fromJson(json))
              .toList();

        } else {
          throw Exception(body['message'] ?? 'Format data salah');
        }
      } else {
        throw Exception('Gagal memuat pesan. Status: ${response.statusCode}');
      }
    } catch (e) {
      errorMessage(e.toString());
      print(e);
    } finally {
      isLoading(false);
    }
  }

  // Fungsi untuk pull-to-refresh
  Future<void> refresh() async {
    fetchSentMessages();
  }

  // Fungsi untuk navigasi ke detail (jika perlu)
  void viewMessageDetail(SentMessage message) {
    // Arahkan ke halaman detail pesan jika ada
    Get.snackbar(
        'Membuka Pesan',
        'Kepada: ${message.receiverUsername}\nIsi: ${message.messageText}'
    );
  }

  Future<bool> confirmDelete(int messageId) async {
    // Tampilkan dialog konfirmasi
    bool? confirmed = await Get.defaultDialog<bool>(
      title: "Hapus Pesan",
      middleText: "Apakah Anda yakin ingin menghapus pesan ini secara permanen?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    if (confirmed == true) {
      // Jika user konfirmasi "Ya", panggil API
      return await _executeDelete(messageId);
    }
    return false;
  }

  // --- 5. TAMBAHKAN FUNGSI UNTUK EKSEKUSI API DELETE ---
  Future<bool> _executeDelete(int messageId) async {
    try {
      // Panggil endpoint DELETE
      final Uri url = Uri.parse('$host/api/messages/$messageId');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'user_id': currentUserId,
        }),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        if (body['success'] == true) {
          // Hapus dari list UI secara reaktif
          sentMessages.removeWhere((msg) => msg.id == messageId);
          Get.snackbar(
            "Sukses",
            body['message'] ?? "Pesan berhasil dihapus",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          return true; // Berhasil, izinkan item di-dismiss
        } else {
          throw Exception(body['message'] ?? 'Gagal menghapus pesan');
        }
      } else {
        throw Exception('Error: Gagal menghapus pesan. Server mungkin sedang tidak aktif :(');
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal menghapus pesan, coba lagi.\n",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false; // Gagal, jangan dismiss (item akan swipe back)
    }
  }
}
