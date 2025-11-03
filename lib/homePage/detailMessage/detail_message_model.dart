import 'package:intl/intl.dart'; // Anda perlu package 'intl' di pubspec.yaml

// Model untuk lampiran (attachment)
class Attachment {
  final int id;
  final String filename;
  final String fileType;
  final int fileSize;
  final String downloadUrl;

  Attachment({
    required this.id,
    required this.filename,
    required this.fileType,
    required this.fileSize,
    required this.downloadUrl,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      filename: json['filename'],
      fileType: json['file_type'],
      fileSize: json['file_size'],
      downloadUrl: json['download_url'],
    );
  }
}

// Model untuk detail pesan
class MessageDetail {
  final int id;
  final int senderId;
  final String senderUsername;
  final String senderEmail;
  final int receiverId;
  final String receiverUsername;
  final String receiverEmail;
  final String messageText;
  final String createdAt;
  final List<Attachment> attachments;

  MessageDetail({
    required this.id,
    required this.senderId,
    required this.senderUsername,
    required this.senderEmail,
    required this.receiverId,
    required this.receiverUsername,
    required this.receiverEmail,
    required this.messageText,
    required this.createdAt,
    required this.attachments,
  });

  factory MessageDetail.fromJson(Map<String, dynamic> json) {
    var attachmentsList = json['attachments'] as List;
    List<Attachment> attachments = attachmentsList
        .map((attJson) => Attachment.fromJson(attJson))
        .toList();

    return MessageDetail(
      id: json['id'],
      senderId: json['sender_id'],
      senderUsername: json['sender_username'],
      senderEmail: json['sender_email'],
      receiverId: json['receiver_id'],
      receiverUsername: json['receiver_username'],
      receiverEmail: json['receiver_email'],
      messageText: json['message_text'], // Ini sudah decrypted dari API
      createdAt: json['created_at'],
      attachments: attachments,
    );
  }

  // Helper untuk format tanggal
  String get formattedDate {
    try {
      final DateTime dt = DateTime.parse(createdAt);
      // Format: "1 Nov 2025, 10:30"
      return DateFormat('d MMM yyyy, HH:mm').format(dt);
    } catch (e) {
      return createdAt.split('T').first;
    }
  }
}