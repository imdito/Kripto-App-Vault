// lib/models/message_model.dart

import 'dart:io';

class Message {
  final int id;
  final String senderUsername;
  final String senderEmail;
  final String messageText;
  final DateTime createdAt; // Kita ubah jadi DateTime agar mudah diformat

  Message({
    required this.id,
    required this.senderUsername,
    required this.senderEmail,
    required this.messageText,
    required this.createdAt,
  });

  // Factory constructor untuk mengubah JSON menjadi objek Message
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      senderUsername: json['sender_username'] as String,
      senderEmail: json['sender_email'] as String,
      messageText: json['message_text'] as String,
      createdAt: HttpDate.parse(json['created_at'] as String),
    );
  }
}