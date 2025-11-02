import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'file_encrypt_controller.dart';


class FileEncryptView extends GetView<FileEncryptController> {
  const FileEncryptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enkripsi File (GetX)')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bungkus dengan Obx untuk menonaktifkan tombol saat loading
            Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoading.value ? null : controller.pickFile,
              icon: Icon(Icons.folder_open),
              label: Text('Pilih File'),
            )),

            SizedBox(height: 16),

            // Password input
            TextField(
              controller: controller.passwordController, // Ambil dari controller
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),

            SizedBox(height: 16),

            // Tombol Enkripsi
            Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoading.value ? null : controller.encryptFile,
              icon: Icon(Icons.lock),
              label: Text('Enkripsi File'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            )),

            SizedBox(height: 8),

            // Tombol Dekripsi
            Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoading.value ? null : controller.decryptFile,
              icon: Icon(Icons.lock_open),
              label: Text('Dekripsi File'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            )),

            SizedBox(height: 24),

            // Status (bereaksi terhadap isLoading)
            Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              } else {
                // Card Status (bereaksi terhadap status.value)
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      controller.status.value, // Ambil dari controller
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}