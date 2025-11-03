import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'detail_message_controller.dart';
import 'detail_message_model.dart'; // Impor model

class DetailMassageView extends GetView<DetailMessageController> {
  const DetailMassageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesan'),
      ),
      body: Obx(() {
        // 1. STATE LOADING
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        // 2. STATE ERROR
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Error: ${controller.errorMessage.value}'),
            ),
          );
        }

        // 3. STATE SUKSES (ADA DATA)
        final msg = controller.message.value;
        if (msg == null) {
          return Center(child: Text('Pesan tidak ditemukan.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Info ---
              _buildHeaderInfo('DARI:', msg.senderUsername, msg.senderEmail),
              _buildHeaderInfo('KEPADA:', msg.receiverUsername, msg.receiverEmail),
              _buildHeaderInfo('TANGGAL:', msg.formattedDate, null),

              Divider(height: 32, thickness: 1),

              // --- Isi Pesan ---
              Text(
                'Isi Pesan:',
                style: Get.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  msg.messageText,
                  style: Get.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ),

              SizedBox(height: 24),

              // --- Bagian Lampiran (Attachments) ---
              if (msg.attachments.isNotEmpty)
                _buildAttachmentsSection(msg.attachments),
            ],
          ),
        );
      }),
    );
  }

  // Helper untuk header (Dari, Kepada, Tanggal)
  Widget _buildHeaderInfo(String label, String value, String? subValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
                if (subValue != null)
                  Text(subValue, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk bagian lampiran
  Widget _buildAttachmentsSection(List<Attachment> attachments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lampiran (${attachments.length}):',
          style: Get.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Obx(() => Opacity(
          // Redupkan tombol saat sedang download
          opacity: controller.isDownloading.value ? 0.5 : 1.0,
          child: ListView.builder(
            shrinkWrap: true, // Agar list tidak mengambil full height
            physics: NeverScrollableScrollPhysics(),
            itemCount: attachments.length,
            itemBuilder: (context, index) {
              final att = attachments[index];
              // Cek apakah file melebihi 10MB
              bool isTooLarge = att.fileSize > (10 * 1024 * 1024);

              return Card(
                elevation: 1,
                child: ListTile(
                  leading: Icon(
                    isTooLarge ? Icons.error_outline : Icons.description_outlined,
                    color: isTooLarge ? Colors.red : Colors.blueAccent,
                  ),
                  title: Text(att.filename, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    controller.formatBytes(att.fileSize) +
                        (isTooLarge ? " (Melebihi 10MB)" : ""),
                    style: TextStyle(color: isTooLarge ? Colors.red : null),
                  ),
                  trailing: controller.isDownloading.value
                      ? CircularProgressIndicator(strokeWidth: 2)
                      : Icon(Icons.download_for_offline_outlined),
                  onTap: (controller.isDownloading.value || isTooLarge)
                      ? null // Nonaktifkan tap jika sedang download ATAU file terlalu besar
                      : () => controller.downloadAttachment(att),
                ),
              );
            },
          ),
        )),
      ],
    );
  }
}