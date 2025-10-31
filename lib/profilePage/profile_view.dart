import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kripto_app/profilePage/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  late final String username;
  late final String email;
  late final int id;
  late final ProfileController controller;

  ProfileView({Key? key}) : super(key: key) {
    username = Get.arguments["username"] ?? "User";
    email = Get.arguments["email"] ?? "email@email.com";
    id = Get.arguments["id"] ?? 0;
    controller = Get.find<ProfileController>();
    controller.idUser.value = id;
    controller.userName.value = username;
    controller.userEmail.value = email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya 👤'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // --- HEADER PROFIL ---
          _buildProfileHeader(),

          const SizedBox(height: 20),

          // --- BAGIAN MENU AKUN ---
          _buildSectionHeader("Akun"),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Edit Profil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.editProfile,
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('Notifikasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.goToNotifications,
          ),

          const Divider(height: 30),

          // --- BAGIAN MENU KEAMANAN ---
          _buildSectionHeader("Keamanan"),
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: const Text('Ubah Master PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.changeMasterPin,
          ),

          // --- MENU TAMBAH BIOMETRIC (SESUAI REQUEST) ---
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Tambah / Atur Biometrik'),
            subtitle: const Text('Gunakan sidik jari atau Face ID'),
            trailing: const Icon(Icons.chevron_right),
            onTap: controller.addBiometric,
          ),

          const Divider(height: 30),

          // --- MENU LOGOUT ---
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade700),
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.red.shade700),
            ),
            onTap: controller.logout,
          ),
        ],
      ),
    );
  }

  // --- Widget Helper untuk Header ---
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            // Gunakan Obx untuk data reaktif dari controller
            Obx(() => Text(
              controller.userName.value,
              style: Get.textTheme.headlineSmall,
            )),
            const SizedBox(height: 4),
            Obx(() => Text(
              controller.userEmail.value,
              style: Get.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            )),
          ],
        ),
      ),
    );
  }

  // --- Widget Helper untuk Judul Section ---
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.indigo.shade800,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
