import 'package:intl/intl.dart'; // Tambahkan package 'intl' di pubspec.yaml

class SentMessage {
  final int id;
  final int receiverId;
  final String receiverUsername;
  final String receiverEmail;
  final String messageText;
  final String createdAt;

  SentMessage({
    required this.id,
    required this.receiverId,
    required this.receiverUsername,
    required this.receiverEmail,
    required this.messageText,
    required this.createdAt,
  });

  factory SentMessage.fromJson(Map<String, dynamic> json) {
    return SentMessage(
      id: json['id'],
      receiverId: json['receiver_id'],
      receiverUsername: json['receiver_username'],
      receiverEmail: json['receiver_email'],
      messageText: json['message_text'],
      createdAt: json['created_at'],
    );
  }

  // Helper untuk format tanggal
  String get formattedDate {
    try {
      final DateTime dt = DateTime.parse(createdAt);
      // Format: "03 Nov, 10:30"
      return DateFormat('EEE, M/d/y').format(dt);
    } catch (e) {
      // Jika parsing gagal, kembalikan tanggal mentah
      return createdAt.split('T').first;
    }
  }
}