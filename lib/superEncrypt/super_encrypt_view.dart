import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kripto_app/superEncrypt/super_encrypt_controller.dart';

class SuperEncryptView extends GetView<SuperEncryptController> {
  const SuperEncryptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enkripsi Teks Catatan 📝'),
        actions: [
          // Tombol untuk membersihkan layar
          IconButton(
            icon: Icon(Icons.clear_all),
            tooltip: "Bersihkan",
            onPressed: controller.clearFields,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- INPUT TEKS ---
            TextField(
              controller: controller.textInputController,
              decoration: const InputDecoration(
                labelText: 'Teks Input (Plainteks / Chiperteks)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
            ),
            const SizedBox(height: 16),

            // --- INPUT KUNCI ---
            TextField(
              controller: controller.keyController,
              obscureText: true, // Sembunyikan kunci
              decoration: const InputDecoration(
                labelText: 'Kunci Rahasia',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key_outlined),
              ),
            ),
            const SizedBox(height: 24),

            // --- TOMBOL AKSI (Enkripsi & Dekripsi) ---
            Obx(() => Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Enkripsi'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue, // Warna biru
                    ),
                    // Disable tombol saat loading
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.encryptText,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.lock_open_outlined),
                    label: const Text('Dekripsi'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green, // Warna hijau
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.decryptText,
                  ),
                ),
              ],
            )),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // --- AREA HASIL ---
            _buildResultArea(),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk menampilkan hasil
  Widget _buildResultArea() {
    return Obx(() {
      // Tampilkan spinner jika loading
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // Jangan tampilkan apa-apa jika hasil masih kosong
      if (controller.resultText.value.isEmpty) {
        return Center(
          child: Text(
            "Hasil akan muncul di sini...",
            style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        );
      }

      // Tampilkan hasil jika sudah ada
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hasil:",
                style: Get.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              // Tombol untuk menyalin hasil
              IconButton(
                icon: const Icon(Icons.copy_all_outlined),
                tooltip: "Salin Hasil",
                onPressed: controller.copyToClipboard,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: SelectableText( // Agar teks bisa di-copy manual
              controller.resultText.value,
              style: Get.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ],
      );
    });
  }
}