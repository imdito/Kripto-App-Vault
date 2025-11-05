import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kripto_app/sendMessage/send_message_controller.dart';

class SendMessageView extends GetView<SendMessageController> {
  const SendMessageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kirim Pesan (GetX)')),
      body: SingleChildScrollView( // Tambahkan SingleChildScrollView
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Agar tombol full-width
          children: [
            TextField(
              controller: controller.receiverController,
              decoration: InputDecoration(
                labelText: 'Email Penerima',
                hintText: 'user@example.com',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                labelText: 'Pesan',
                hintText: 'Tulis pesan Anda...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),

            // --- BAGIAN ATTACHMENT ---
            OutlinedButton.icon(
              onPressed: controller.pickAttachments,
              icon: Icon(Icons.attach_file),
              label: Text("Tambah Lampiran"),
              style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12)
              ),
            ),
            SizedBox(height: 8),

            // List lampiran yang dipilih
            Obx(() {
              if (controller.attachments.isEmpty) {
                return SizedBox.shrink(); // Jangan tampilkan apa-apa
              }
              // Tampilkan list jika ada file
              return Container(
                height: 150, // Batasi tinggi list
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300)
                ),
                child: ListView.builder(
                  itemCount: controller.attachments.length,
                  itemBuilder: (context, index) {
                    final file = controller.attachments[index];
                    return _buildAttachmentTile(file);
                  },
                ),
              );
            }),
            // --- AKHIR BAGIAN ATTACHMENT ---

            SizedBox(height: 24),

            // Tombol Kirim
            Obx(() => ElevatedButton.icon(
              icon: Icon(Icons.send),
              label: Text('Kirim Pesan'),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16)
              ),
              onPressed: controller.isLoading.value ? null : controller.sendMessage,
            )),

            // Tampilkan loading indicator di bawah tombol
            Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk menampilkan file di list
  Widget _buildAttachmentTile(File file) {
    return ListTile(
      leading: Icon(Icons.description),
      title: Text(
        file.path.split('/').last, // Ambil nama file
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(Icons.close, color: Colors.red),
        onPressed: () => controller.removeAttachment(file), // Panggil fungsi hapus
      ),
    );
  }
}