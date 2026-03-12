class Chat {
  final int id;
  final int orderId;
  final int customerId;
  final int? driverId;
  final String status;
  final String createdAt;
  final String updatedAt;
  final List<ChatMessage>? messages;

  Chat({
    required this.id,
    required this.orderId,
    required this.customerId,
    this.driverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.messages,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? json['chat_id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      driverId: json['driver_id'],
      status: json['status'] ?? 'ACTIVE',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((i) => ChatMessage.fromJson(i))
              .toList()
          : null,
    );
  }
}

// Chat List Model (for chat list page)
class ChatModel {
  final int id;
  final int recipientId;
  final String recipientName;
  final String recipientType; // MERCHANT, COURIER, USER
  final int? orderId;
  final String? lastMessage;
  final String? lastMessageAt;
  int? unreadCount; // Changed to non-final for updates
  final String? recipientAvatar;

  ChatModel({
    required this.id,
    required this.recipientId,
    required this.recipientName,
    required this.recipientType,
    this.orderId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount,
    this.recipientAvatar,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? 0,
      recipientId: json['recipient_id'] ?? 0,
      recipientName: json['recipient_name'] ?? 'Unknown',
      recipientType: json['recipient_type'] ?? 'USER',
      orderId: json['order_id'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'],
      unreadCount: json['unread_count'],
      recipientAvatar: json['recipient_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'recipient_name': recipientName,
      'recipient_type': recipientType,
      'order_id': orderId,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt,
      'unread_count': unreadCount,
      'recipient_avatar': recipientAvatar,
    };
  }
}

class ChatMessage {
  final int id;
  final int chatId;
  final int senderId;
  final String? message;
  final String type; // 'TEXT', 'IMAGE', 'LOCATION'
  final String? attachmentUrl; // For images
  final double? latitude; // For location messages
  final double? longitude; // For location messages
  final double? locationAccuracy; // GPS accuracy in meters
  final String? locationAddress; // Human-readable address
  final String? locationName; // Location name/label
  final bool isRead;
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.message,
    required this.type,
    this.attachmentUrl,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    this.locationAddress,
    this.locationName,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Parse location_data if it exists (nested object from backend)
    Map<String, dynamic>? locationData;
    if (json['location_data'] != null && json['location_data'] is Map<String, dynamic>) {
      locationData = json['location_data'] as Map<String, dynamic>;
    }

    return ChatMessage(
      id: int.tryParse(json['id'].toString()) ?? 0,
      chatId: int.tryParse(json['chat_id'].toString()) ?? 0,
      senderId: int.tryParse(json['sender_id'].toString()) ?? 0,
      message: json['message'],
      type: json['type'] ?? 'TEXT',
      attachmentUrl: json['attachment_url'],
      // Prefer direct fields, fallback to location_data object
      latitude: locationData != null && locationData['latitude'] != null
          ? (locationData['latitude'] as num).toDouble()
          : (json['latitude'] != null ? (json['latitude'] as num).toDouble() : null),
      longitude: locationData != null && locationData['longitude'] != null
          ? (locationData['longitude'] as num).toDouble()
          : (json['longitude'] != null ? (json['longitude'] as num).toDouble() : null),
      locationAccuracy: locationData != null && locationData['accuracy'] != null
          ? (locationData['accuracy'] as num).toDouble()
          : (json['location_accuracy'] != null ? (json['location_accuracy'] as num).toDouble() : null),
      locationAddress: locationData != null && locationData['address'] != null
          ? locationData['address']
          : json['location_address'],
      locationName: locationData != null && locationData['name'] != null
          ? locationData['name']
          : json['location_name'],
      isRead: json['is_read'] == 1 ||
          json['is_read'] == true ||
          json['is_read'] == '1' ||
          json['read_at'] != null,
      createdAt: json['created_at'],
    );
  }

  // Check if message is an image
  bool get isImage => type == 'IMAGE';

  // Check if message is a location
  bool get isLocation => type == 'LOCATION';

  // Check if message is text
  bool get isText => type == 'TEXT';

  // Get Google Maps URL for location messages
  String? get googleMapsUrl {
    if (latitude == null || longitude == null) return null;
    return 'https://www.google.com/maps?q=$latitude,$longitude';
  }
}

/// Paginated response for chat messages
class PaginatedMessages {
  final List<ChatMessage> messages;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;
  final bool hasMorePages;

  PaginatedMessages({
    required this.messages,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
    required this.hasMorePages,
  });
}
