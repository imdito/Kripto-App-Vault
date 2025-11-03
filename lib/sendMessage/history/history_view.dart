import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesan Terkirim 📤'),
      ),
      // Gunakan Obx untuk merender UI berdasarkan state controller
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
              child: Text(
                'Error: ${controller.errorMessage.value}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // 3. STATE KOSONG
        if (controller.sentMessages.isEmpty) {
          return Center(
            child: Text('Anda belum mengirim pesan apapun.'),
          );
        }

        // 4. STATE SUKSES (ADA DATA)
        // Gunakan RefreshIndicator untuk pull-to-refresh
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            itemCount: controller.sentMessages.length,
            itemBuilder: (context, index) {
              final message = controller.sentMessages[index];

              return ListTile(
                leading: CircleAvatar(
                  child: Text(message.receiverUsername[0].toUpperCase()),
                  backgroundColor: Colors.blueGrey,
                ),
                title: Text(
                  'Kepada: ${message.receiverUsername}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.messageText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      message.formattedDate, // Gunakan helper format tanggal
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: IconButton(onPressed: (){controller.confirmDelete(message.id);}, icon: Icon(Icons.delete, color: Colors.red,)),

                onTap: () {
                  controller.viewMessageDetail(message);
                },
              );;
            },
          ),
        );
      }),
    );
  }
}