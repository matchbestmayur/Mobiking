// lib/models/query_model.dart
import 'package:uuid/uuid.dart';


final Uuid _uuid = Uuid();

class QueryModel {
  final String id;
  String title;
  String message;
  final String userEmail;
  List<ReplyModel> replies; // List of replies for this query
  final DateTime createdAt;
  bool isRead; // To mark if query has unread replies or is resolved

  QueryModel({
    required this.id,
    required this.title,
    required this.message,
    required this.userEmail,
    List<ReplyModel>? replies,
    DateTime? createdAt,
    this.isRead = false,
  }) : replies = replies ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Factory constructor to create a QueryModel from a Map (e.g., JSON)
  factory QueryModel.fromJson(Map<String, dynamic> json) {
    return QueryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      userEmail: json['userEmail'] as String,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => ReplyModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
    );
  }

  // Method to convert a QueryModel to a Map (e.g., JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'userEmail': userEmail,
      'replies': replies.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}

/// Represents a single message (reply) within a query's conversation
class MessageModel {
  final String id;
  final String queryId;
  final String sender; // 'user' or 'admin'
  final String text;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.queryId,
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  // Factory constructor to create a MessageModel from a map
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      queryId: map['queryId'] as String,
      sender: map['sender'] as String,
      text: map['text'] as String,
      timestamp: map['timestamp'] as DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'queryId': queryId,
      'sender': sender,
      'text': text,
      'timestamp': timestamp,
    };
  }
}


class ReplyModel {
  final String id;
  final String userId; // Or userEmail, to identify who sent it
  final String replyText;
  final DateTime timestamp;
  final bool isAdmin; // true if admin, false if user

  ReplyModel({
    required this.id,
    required this.userId,
    required this.replyText,
    DateTime? timestamp,
    this.isAdmin = false,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      replyText: json['replyText'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isAdmin: json['isAdmin'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'replyText': replyText,
      'timestamp': timestamp.toIso8601String(),
      'isAdmin': isAdmin,
    };
  }
}