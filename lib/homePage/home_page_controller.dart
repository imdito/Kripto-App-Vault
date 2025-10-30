import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_page_model.dart';

class HomePageController extends GetxController {

  // --- STATE ---
  // Gunakan .obs untuk membuat variabel menjadi reaktif (Rx)
  var isLoading = true.obs;
  var vaultItems = <VaultItem>[].obs; // List reaktif untuk item brankas

  // --- LIFECYCLE ---
  @override
  void onInit() {
    super.onInit();
    fetchVaultItems(); // Panggil data saat controller dimuat
  }

  // --- LOGIC ---

  // Simulasi pengambilan data dari database/Google Drive
  Future<void> fetchVaultItems() async {
    try {
      isLoading(true);
      // Simulasi delay jaringan
      await Future.delayed(const Duration(seconds: 1));

      // DATA DUMMY (ganti dengan logika fetch Anda)
      var dummyData = [
        VaultItem(
            id: '1',
            title: "Daftar Password Bank",
            type: VaultItemType.note,
            lastModified: DateTime.now().subtract(const Duration(days: 1))),
        VaultItem(
            id: '2',
            title: "Scan KTP & KK.zip",
            type: VaultItemType.file,
            lastModified: DateTime.now().subtract(const Duration(days: 2))),
        VaultItem(
            id: '3',
            title: "Foto Liburan (Rahasia)",
            type: VaultItemType.steganography,
            lastModified: DateTime.now().subtract(const Duration(days: 3))),
      ];

      // Untuk tes state kosong, uncomment baris ini:
      // var dummyData = <VaultItem>[];

      // Masukkan data ke list reaktif
      vaultItems.assignAll(dummyData);

    } finally {
      isLoading(false);
    }
  }

  // Aksi saat item di-tap
  void openItem(VaultItem item) {
    print("Membuka item: ${item.title}");
    // Tampilkan dialog otentikasi (sidik jari/PIN)
    // Get.toNamed('/detail-item', arguments: item.id);
    Get.snackbar(
      "Otentikasi Diperlukan",
      "Buka item '${item.title}' setelah verifikasi biometrik.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Aksi untuk tombol FAB (+)
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
                Get.back(); // Tutup bottom sheet
                // Get.toNamed('/add-note'); // Navigasi ke halaman tambah catatan
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Upload File Aman'),
              onTap: () {
                Get.back();
                // Get.toNamed('/add-file');
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Sembunyikan Pesan di Gambar'),
              onTap: () {
                Get.back();
                // Get.toNamed('/add-steganography');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Aksi untuk tombol logout di drawer
  void logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Apakah Anda yakin ingin keluar dari SecureVault?",
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Lakukan proses clear session/token
        Get.offAllNamed('/login'); // Navigasi ke login & hapus riwayat
      },
    );
  }
}