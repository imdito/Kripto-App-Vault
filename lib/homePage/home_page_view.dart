import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kripto_app/homePage/home_page_controller.dart';

import '../LoginRegister/signin_up_controller.dart';
import 'home_page_model.dart';


// Gunakan GetView untuk akses controller secara otomatis
class HomePageView extends GetView<HomePageController> {
    String username = Get.arguments["username"] ?? "User";
    String email = Get.arguments["email"] ?? "email@email.com";
    int id = Get.arguments["id"] ?? 0;

  HomePageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APPBAR ---
      appBar: AppBar(
        title: Text("Brankas id: ${id}", ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () { /* Panggil controller.search() */ },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () { /* Panggil controller.filter() */ },
          ),
        ],
      ),

      // --- DRAWER (MENU SAMPING) ---
      drawer: _buildDrawer(),

      // --- TOMBOL AKSI UTAMA (FAB) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Panggil method dari controller
          controller.showAddItemSheet();
        },
        child: const Icon(Icons.add),
      ),

      // --- BODY UTAMA ---
      // Bungkus body dengan Obx untuk membuatnya reaktif
      body: Obx(() {
        // 1. Jika masih loading, tampilkan spinner
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Jika data kosong, tampilkan state kosong
        if (controller.vaultItems.isEmpty) {
          return _buildEmptyState();
        }

        // 3. Jika ada data, tampilkan list
        return _buildVaultList();
      }),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username), // Ganti dengan data user
            accountEmail: Text(email), // Ganti
            currentAccountPicture: const CircleAvatar(
              child: Text("U"),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Pengaturan Profil'),
            onTap: (){
              Get.toNamed('/profile', arguments:
              {
                "id": id,
                "username": username,
                "email": email
              }
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            onTap: () { /* Navigasi ke about */ },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade700),
            title: const Text('Logout'),
            onTap: () {
              // Panggil method logout dari controller
              controller.logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_open_outlined, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              "Brankas Anda Masih Kosong",
              style: Get.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Tekan tombol '+' di bawah untuk menambahkan catatan rahasia, file, atau gambar pertama Anda.",
              style: Get.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultList() {
    // Listview ini otomatis update karena dibungkus Obx di body
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: controller.vaultItems.length,
      itemBuilder: (context, index) {
        final item = controller.vaultItems[index];
        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(_getIconForItem(item.type)),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Tipe: ${_getTypeString(item.type)}\nDiubah: ${_formatDate(item.lastModified)}",
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              controller.openItem(item);
            },
          ),
        );
      },
    );
  }

  // --- HELPER METHODS (UNTUK UI) ---

  IconData _getIconForItem(VaultItemType type) {
    switch (type) {
      case VaultItemType.note:
        return Icons.note_alt_outlined; // 📝
      case VaultItemType.file:
        return Icons.folder_zip_outlined; // 📄
      case VaultItemType.steganography:
        return Icons.image_search_outlined; // 🖼️
    }
  }

  String _getTypeString(VaultItemType type) {
    switch (type) {
      case VaultItemType.note:
        return "Catatan Teks";
      case VaultItemType.file:
        return "File Terenkripsi";
      case VaultItemType.steganography:
        return "Gambar (Steganografi)";
    }
  }

  String _formatDate(DateTime date) {
    // Format tanggal sederhana, bisa diganti dengan package 'intl'
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}";
  }
}