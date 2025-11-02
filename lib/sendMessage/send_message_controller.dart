import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// ❗ Asumsi Anda memiliki file service ini
// import 'package:kripto_app/services/message_service.dart';

// ❗ Placeholder service jika Anda belum memilikinya
class MessageService {
  Future<Map<String, dynamic>> sendMessage({
    required int senderId,
    required String receiverEmail,
    required String messageText,
  }) async {
    try {
      String? host = dotenv.env['API_HOST'];
      final url = Uri.parse('$host/api/messages/send');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'sender_id': senderId,
          'receiver_email': receiverEmail,
          'message_text': messageText,
        }),
      );
    }catch(e){
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
    await Future.delayed(const Duration(seconds: 2));
    print("Sending message from $senderId to $receiverEmail");
    // Simulasi sukses
    return {'success': true, 'message': 'Pesan berhasil terkirim'};
  }
}

class SendMessageController extends GetxController {
  final _messageService = MessageService();
  late TextEditingController receiverController;
  late TextEditingController messageController;

  // --- STATE REAKTIF ---
  var isLoading = false.obs;

  // --- DATA DARI HALAMAN SEBELUMNYA ---
  late int currentUserId = Get.arguments as int;

  // --- LIFECYCLE ---
  @override
  void onInit() {
    super.onInit();
    // Inisialisasi controller
    receiverController = TextEditingController();
    messageController = TextEditingController();

    // Ambil currentUserId dari argumen navigasi
    // Panggil halaman ini menggunakan:
    // Get.toNamed('/send-message', arguments: 123); // (ganti 123 dengan ID user)
    currentUserId = Get.arguments as int;
  }

  @override
  void onClose() {
    // Selalu dispose controller
    receiverController.dispose();
    messageController.dispose();
    super.onClose();
  }

  // --- LOGIKA AKSI ---
  Future<void> sendMessage() async {
    if (receiverController.text.isEmpty || messageController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email penerima dan pesan harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading(true); // Mulai loading

    try {
      final result = await _messageService.sendMessage(
        senderId: currentUserId, // Ambil dari properti
        receiverEmail: receiverController.text,
        messageText: messageController.text,
      );

      if (result['success']) {
        Get.snackbar(
          'Sukses',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        messageController.clear();
        receiverController.clear();
      } else {
        Get.snackbar(
          'Gagal',
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false); // Selesai loading
    }
  }
}