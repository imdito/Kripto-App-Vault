import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kripto_app/superEncrypt/super_encrypt_controller.dart';

// Ganti dari StatefulWidget menjadi GetView
class SuperEncryptView extends GetView<SuperEncryptController> {
  const SuperEncryptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Super Encrypt')),
      // Tambahkan SingleChildScrollView agar tidak overflow
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller.textController, // Gunakan controller
              decoration: InputDecoration(labelText: 'Text'),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.caesarController, // Gunakan controller
                    decoration: InputDecoration(labelText: 'Caesar Shift'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.vigenereController, // Gunakan controller
                    decoration: InputDecoration(labelText: 'Vigenere Key'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            TextField(
              controller: controller.desController, // Gunakan controller
              decoration: InputDecoration(labelText: 'DES Key'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller.ivController, // Gunakan controller
              decoration: InputDecoration(labelText: 'iv (saat decrypt)'),
            ),
            SizedBox(height: 16),

            // Bungkus tombol dengan Obx untuk memantau isLoading
            Obx(() => Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    // Nonaktifkan tombol saat loading
                    onPressed: controller.isLoading.value ? null : controller.encrypt,
                    child: Text('Encrypt'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    // Nonaktifkan tombol saat loading
                    onPressed: controller.isLoading.value ? null : controller.decrypt,
                    child: Text('Decrypt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            )),

            SizedBox(height: 16),

            GestureDetector(
              onLongPress: ()=> controller.copyResultToClipboard("Chipertext"),
              child: Obx(() => Card(
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  child: Text(
                    controller.result.value.isEmpty
                        ? "Hasil akan muncul di sini..."
                        : controller.result.value,
                  ),
                ),
              )),
            ),
            GestureDetector(
              onLongPress: ()=> controller.copyResultToClipboard("iv"),
              child: Obx(() => Card(
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  child: Text(
                    controller.result.value.isEmpty
                        ? "iv akan muncul di sini..."
                        : controller.encryptedData.value?['iv'] == null
                            ? "iv tidak tersedia"
                            : "✅ iv: ${controller.encryptedData.value!['iv']}",
                  ),
                ),
              )),
            ),

            Obx(() {
              if (controller.isLoading.value) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                );
              }
              return SizedBox.shrink(); // Kosong jika tidak loading
            }),
          ],
        ),
      ),
    );
  }
}