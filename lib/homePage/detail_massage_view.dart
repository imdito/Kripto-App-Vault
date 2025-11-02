import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_page_model.dart'; // Pastikan path ke model Anda benar

class DetailMassageView extends StatelessWidget {
  DetailMassageView({Key? key}) : super(key: key);
  final senderUsername = Get.arguments["senderUsername"];
  final messageText = Get.arguments["messageText"] ?? "Tidak ada pesan.";
  final senderEmail = Get.arguments["senderEmail"] ?? "sender@email.com";
  final createdAt = Get.arguments["createdAt"] ?? DateTime.now();
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} pukul ${date.hour}:${date.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Tampilkan nama pengirim di AppBar
        title: Text(senderUsername),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Bagian Header (Info Pengirim) ---
              Text(
                "Detail Pesan",
                style: Get.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.person_outline,
                label: "Dari",
                value: senderUsername,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: "Email",
                value: senderEmail,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.access_time_outlined,
                label: "Diterima",
                value: _formatDate(createdAt),
              ),

              const Divider(height: 32.0), // Garis pemisah

              // --- Bagian Isi Pesan ---
              Text(
                "Isi Pesan:",
                style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Latar belakang abu-abu
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  messageText,
                  // Biarkan font lebih besar agar mudah dibaca
                  style: Get.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk membuat baris info (Icon - Label - Value)
  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 16),
        // Label (e.g., "Dari", "Email")
        SizedBox(
          width: 70, // Beri jarak tetap agar rapi
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
        const Text(": "),
        // Value (Isi datanya)
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}