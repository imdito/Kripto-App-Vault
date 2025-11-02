import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kripto_app/sendMessage/send_message_controller.dart';

// Ganti dari StatefulWidget menjadi GetView
class SendMessageView extends GetView<SendMessageController> {
  const SendMessageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kirim Pesan (GetX)')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller.receiverController, // Gunakan controller
              decoration: InputDecoration(
                labelText: 'Email Penerima',
                hintText: 'user@example.com',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.messageController, // Gunakan controller
              decoration: InputDecoration(
                labelText: 'Pesan',
                hintText: 'Tulis pesan Anda...',
              ),
              maxLines: 5,
            ),
            SizedBox(height: 24),

            // Bungkus Tombol dengan Obx
            Obx(() => ElevatedButton(
              // Nonaktifkan tombol saat loading
              onPressed: controller.isLoading.value ? null : controller.sendMessage,
              child: controller.isLoading.value
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text('Kirim Pesan'),
            )),
          ],
        ),
      ),
    );
  }
}