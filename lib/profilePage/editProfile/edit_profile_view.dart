import 'package:flutter/material.dart';
import 'edit_profile_controller.dart';
import 'package:get/get.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          // Bungkus dengan Form untuk validasi
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ilustrasi atau foto profil bisa ditambahkan di sini
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 32),

                // --- Form Field Password ---
                TextFormField(
                  controller: controller.passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password Baru',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.password_outlined),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                ),
                //form old password
                const SizedBox(height: 40),
                TextFormField(
                  controller: controller.oldPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Password lama',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.password_outlined),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                ),
                const SizedBox(height: 40),


                // --- Tombol Simpan ---
                // Gunakan Obx untuk menampilkan loading di tombol
                Obx(() {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Nonaktifkan tombol saat loading
                    onPressed: controller.isLoading.value ? null : () {
                      controller.saveChanges();
                    },
                    child: controller.isLoading.value
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : const Text(
                      'Simpan Perubahan',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}