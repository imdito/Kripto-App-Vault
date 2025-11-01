import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kripto_app/steganoPage/stegano_controller.dart'; // Sesuaikan

class SteganographyView extends GetView<SteganographyController> {
  const SteganographyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Steganografi (GetX)'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pick Image Button
            ElevatedButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text('Pilih Gambar'),
              onPressed: controller.pickImage, // Panggil dari controller
            ),

            // Tampilkan gambar yang dipilih secara reaktif
            Obx(() {
              if (controller.selectedImage.value != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Image.file(
                    controller.selectedImage.value!,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                );
              } else {
                return const SizedBox.shrink(); // Sembunyikan jika null
              }
            }),

            SizedBox(height: 24),

            // Secret Message Input
            TextField(
              controller: controller.messageController, // Gunakan controller
              decoration: InputDecoration(
                labelText: 'Pesan Rahasia',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              // Hapus onChanged, karena sudah di-handle controller
            ),

            SizedBox(height: 16),

            // Bungkus tombol dengan Obx agar bisa disable saat loading
            Obx(() => ElevatedButton.icon(
              icon: Icon(Icons.lock),
              label: Text('Enkripsi & Simpan'),
              onPressed: controller.isLoading.value
                  ? null // Disable jika loading
                  : controller.encodeMessage, // Panggil dari controller
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            )),

            SizedBox(height: 8),

            // Bungkus tombol dengan Obx agar bisa disable saat loading
            Obx(() => ElevatedButton.icon(
              icon: Icon(Icons.lock_open),
              label: Text('Dekripsi Pesan'),
              onPressed: controller.isLoading.value
                  ? null // Disable jika loading
                  : controller.decodeMessage, // Panggil dari controller
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            )),

            // Tampilkan loading indicator secara reaktif
            Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),
          ],
        ),
      ),
    );
  }
}