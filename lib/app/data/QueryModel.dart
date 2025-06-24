// Path: lib/data/QueryModel.dart

import 'package:uuid/uuid.dart'; // For generating unique IDs

final Uuid _uuid = Uuid(); // Single instance of Uuid for ID generation

// --- QueryModel ---
// Represents a single user query in the system
class QueryModel {
  final String id;
  String title;
  String message; // The initial message of the query
  final String userEmail; // Email of the user who raised the query
  List<ReplyModel> replies; // List of replies to this query
  final DateTime createdAt; // Timestamp when the query record was first created in the system
  bool isRead; // Status indicating if the user has read the latest update/reply on this query

  // Fields to capture more comprehensive query details from the backend
  // The 'status' will now be derived from 'isResolved' if 'status' is not directly provided.
  final String? status; // Current status of the query (e.g., 'open', 'resolved', 'closed', 'pending_reply')
  final String? assignedTo; // Identifier (e.g., ID or name) of the admin/agent it's assigned to
  final DateTime? raisedAt; // Explicit timestamp when query was raised (from backend)
  final DateTime? resolvedAt; // Timestamp when query was officially marked as 'resolved' (from backend)
  final int? rating; // Numerical rating given by the user for the resolution (e.g., 1 to 5 stars)
  final String? review; // Textual review provided by the user along with the rating

  QueryModel({
    required this.id,
    required this.title,
    required this.message,
    required this.userEmail,
    List<ReplyModel>? replies,
    DateTime? createdAt,
    this.isRead = false,
    this.status,
    this.assignedTo,
    this.raisedAt,
    this.resolvedAt,
    this.rating,
    this.review,
  }) : replies = replies ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Factory constructor to create a QueryModel from a JSON map
  factory QueryModel.fromJson(Map<String, dynamic> json) {
    // CRITICAL FIX: Prioritize '_id' from backend, fallback to 'id' if '_id' is not present.
    final String id = json['_id'] as String? ?? json['id'] as String? ?? '';
    final String title = json['title'] as String? ?? '';
    final String message = json['message'] as String? ?? json['description'] as String? ?? '';

    // --- FIX FOR raisedBy: Handle if it's a Map or String for userEmail ---
    String userEmail = '';
    if (json['raisedBy'] is Map<String, dynamic>) {
      userEmail = json['raisedBy']['email'] as String? ?? '';
      print('QueryModel: raisedBy parsed as Map, extracted email: $userEmail'); // Debug print
    } else {
      userEmail = json['raisedBy'] as String? ?? ''; // Fallback for direct string (less common for userId/email)
    }
    // --- END FIX ---

    final DateTime createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();

    // Parse replies: Use the updated ReplyModel.fromJson for each item
    final List<ReplyModel> replies = (json['replies'] as List<dynamic>?)
        ?.map((e) => ReplyModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    final bool isRead = json['isRead'] as bool? ?? false;

    // --- Parsing for new fields ---
    // Handle 'status' or derive from 'isResolved'
    String? status = json['status'] as String?;
    final bool? isResolved = json['isResolved'] as bool?;
    if (status == null && isResolved != null) {
      status = isResolved ? 'resolved' : 'open'; // Derive status from isResolved if 'status' isn't explicitly provided
    }
    // If assignedTo is an object, try to get a name or ID from it
    String? assignedTo;
    if (json['assignedTo'] is Map<String, dynamic>) {
      assignedTo = json['assignedTo']['name'] as String? ?? json['assignedTo']['_id'] as String? ?? json['assignedTo']['id'] as String?;
      print('QueryModel: assignedTo parsed as Map, extracted: $assignedTo'); // Debug print
    } else {
      assignedTo = json['assignedTo'] as String?; // If assignedTo is already a String or null, directly cast it
    }

    final DateTime? raisedAt = DateTime.tryParse(json['raisedAt'] as String? ?? '');
    final DateTime? resolvedAt = DateTime.tryParse(json['resolvedAt'] as String? ?? '');

    // --- Defensive parsing for rating: ensure it's always an int or null ---
    int? rating;
    final dynamic rawRating = json['rating'];
    if (rawRating is int) {
      rating = rawRating;
    } else if (rawRating is String) {
      rating = int.tryParse(rawRating); // Attempt to parse string to int
    }
    // --- END Defensive parsing ---

    final String? review = json['review'] as String?;
    // --- End Parsing for new fields ---

    return QueryModel(
      id: id,
      title: title,
      message: message,
      userEmail: userEmail,
      replies: replies,
      createdAt: createdAt,
      isRead: isRead,
      status: status,
      assignedTo: assignedTo,
      raisedAt: raisedAt,
      resolvedAt: resolvedAt,
      rating: rating, // Use the parsed rating
      review: review,
    );
  }

  // Convert QueryModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      // Note: Backend typically expects '_id' for existing documents, 'id' for new ones.
      // Adjust this based on your backend's specific requirements for PATCH/PUT.
      '_id': id, // Sending _id for update operations
      'id': id, // Also keeping 'id' for consistency if needed elsewhere
      'title': title,
      'message': message,
      'userEmail': userEmail,
      'replies': replies.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'status': status,
      'assignedTo': assignedTo,
      'raisedAt': raisedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'rating': rating,
      'review': review,
    };
  }

  // Static method to create a new QueryModel with a generated ID and timestamp (for local use before backend sync)
  static QueryModel createNew({
    required String title,
    required String message,
    required String userEmail,
  }) {
    return QueryModel(
      id: _uuid.v4(), // Generate a unique ID for new local query
      title: title,
      message: message,
      userEmail: userEmail,
      createdAt: DateTime.now(),
      isRead: false,
      status: 'open', // New queries are typically 'open'
    );
  }

  // Method to add a reply locally to the query (updates the in-memory object)
  void addLocalReply(ReplyModel reply) {
    replies.add(reply);
  }
}

// --- ReplyModel ---
// Represents a single reply within a query
class ReplyModel {
  final String id; // Unique identifier for the reply
  final String userId; // ID of the user (or admin) who made the reply
  final String replyText; // The content of the reply
  final DateTime timestamp; // When the reply was made
  final bool isAdmin; // True if the reply is from an admin

  ReplyModel({
    required this.id,
    required this.userId,
    required this.replyText,
    DateTime? timestamp,
    this.isAdmin = false,
  }) : timestamp = timestamp ?? DateTime.now();

  // Factory constructor to create a ReplyModel from a JSON map
  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    final String id = json['id'] as String? ?? '';
    // --- FIX FOR messagedBy: Handle if it's a Map or String for userId ---
    String userId = '';
    if (json['messagedBy'] is Map<String, dynamic>) {
      userId = json['messagedBy']['_id'] as String? ?? json['messagedBy']['id'] as String? ?? '';
      print('ReplyModel: messagedBy parsed as Map, extracted userId: $userId'); // Debug print
    } else {
      userId = json['messagedBy'] as String? ?? ''; // Fallback for direct string
    }
    // --- END FIX ---

    // Handle 'replyText' or 'message' as the reply content
    final String replyText = json['replyText'] as String? ?? json['message'] as String? ?? '';
    // --- FIX: Parse 'messagedAt' for the timestamp ---
    final DateTime timestamp = DateTime.tryParse(json['messagedAt'] as String? ?? '') ?? DateTime.now();
    // --- END FIX ---
    // Assuming 'messagedBy.role' can determine isAdmin, or a direct 'isAdmin' field exists.
    // If backend provides a direct 'isAdmin' or similar:
    final bool isAdmin = json['isAdmin'] as bool? ?? (json['messagedBy'] is Map<String, dynamic> ? json['messagedBy']['role'] == 'employee' || json['messagedBy']['role'] == 'admin' : false);


    return ReplyModel(
      id: id,
      userId: userId,
      replyText: replyText,
      timestamp: timestamp,
      isAdmin: isAdmin,
    );
  }

  // Convert ReplyModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'replyText': replyText,
      'timestamp': timestamp.toIso8601String(),
      'isAdmin': isAdmin,
    };
  }

  // Static method to create a new ReplyModel with a generated ID and timestamp
  static ReplyModel createNew({
    required String replyText,
    required String userId,
    bool isAdmin = false,
  }) {
    return ReplyModel(
      id: _uuid.v4(), // Generate a unique ID
      userId: userId,
      replyText: replyText,
      timestamp: DateTime.now(),
      isAdmin: isAdmin,
    );
  }
}

// --- MessageModel (kept for compatibility if used elsewhere, but ReplyModel is similar) ---
// This model might be used for generic chat messages, but for replies, ReplyModel is more specific.
// Consider removing if not explicitly used to avoid redundancy.
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

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    final String id = map['id'] as String? ?? '';
    final String queryId = map['queryId'] as String? ?? '';
    final String sender = map['sender'] as String? ?? '';
    final String text = map['text'] as String? ?? '';
    final DateTime timestamp = DateTime.tryParse(map['timestamp'] as String? ?? '') ?? DateTime.now();
    return MessageModel(id: id, queryId: queryId, sender: sender, text: text, timestamp: timestamp);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'queryId': queryId,
      'sender': sender,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// --- Request Models for Backend API Calls ---

class RaiseQueryRequestModel {
  final String title;
  final String description;

  RaiseQueryRequestModel({
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}

class RateQueryRequestModel {
  final int rating;
  final String? review;

  RateQueryRequestModel({
    required this.rating,
    this.review,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'review': review,
    };
  }
}

class ReplyQueryRequestModel {
  final String queryId;
  final String message;

  ReplyQueryRequestModel({
    required this.queryId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'queryId': queryId,
      'message': message,
    };
  }
}

// --- Generic API Response Wrapper ---
class ApiResponse<T> {
  final int statusCode;
  final String message;
  final bool? success;
  final T data;

  ApiResponse({
    required this.statusCode,
    required this.message,
    this.success,
    required this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic json) dataParser,
      ) {
    final int statusCode = json['statusCode'] as int? ?? 500;
    final String message = json['message'] as String? ?? 'Unknown API response message';
    final bool? success = json['success'] as bool?;

    final dynamic rawData = json['data'];
    final T parsedData = dataParser(rawData);

    return ApiResponse(
      statusCode: statusCode,
      message: message,
      success: success,
      data: parsedData,
    );
  }
}
