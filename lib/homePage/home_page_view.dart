import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kripto_app/homePage/home_page_controller.dart';
import 'detail_massage_view.dart';

class HomePageView extends GetView<HomePageController> {

  String username = Get.arguments["username"] ?? "User";
  String email = Get.arguments["email"] ?? "email@email.com";
  int id = Get.arguments["id"] ?? 0;

  HomePageView({Key? key}) : super(key: key);
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- APPBAR ---
      appBar: AppBar(
        // Judul dari kode Anda (SESUAI PERMINTAAN)
        title: Text("Brankas id: ${id}"),
        actions: [
          // Diganti jadi tombol REFRESH (untuk Inbox)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Panggil method refresh dari controller
              controller.fetchMessages(id);
            },
          ),
        ],
      ),

      drawer: _buildDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.showAddItemSheet();
        },
        child: const Icon(Icons.edit), // Icon pensil (tulis)
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Gagal memuat pesan 😥\n${controller.errorMessage.value}",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Coba lagi ambil data
                      controller.fetchMessages(id);
                    },
                    child: Text("Coba Lagi"),
                  )
                ],
              ),
            ),
          );
        }

        if (controller.messages.isEmpty) {
          print("Jumlah Pesan : ${controller.messages.length}");
          print ("id : $id");
          return const Center(
            child: Text("Tidak ada pesan masuk."),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          // PERHATIKAN: Saya ganti 'vaultItems' jadi 'messages'
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            // PERHATIKAN: Saya ganti 'vaultItems' jadi 'messages'
            final message = controller.messages[index];

            return Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    message.senderUsername.isNotEmpty
                        ? message.senderUsername[0].toUpperCase()
                        : "?",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.blueAccent[100],
                ),
                title: Text(
                  message.senderUsername,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  message.messageText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formatDate(message.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Get.to(
                        () => DetailMassageView(),
                    arguments: {
                      'senderUsername': message.senderUsername,
                      'messageText': message.messageText,
                      'createdAt': message.createdAt,
                    },
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username), // Ganti dengan data user
            accountEmail: Text(email), // Ganti
            currentAccountPicture: const CircleAvatar(
              child: Text(
                  (true) ? "U" : "X"
              ),
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
              controller.logout();
            },
          ),
        ],
      ),
    );
  }
}