import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/chat_model.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/config.dart';

class ChatRepository {
  final AuthService _authService = Get.find<AuthService>();
  final String baseUrl = Config.baseUrl;

  Future<List<ChatModel>?> getChatList() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        debugPrint('No auth token found');
        return null;
      }

      debugPrint('Fetching chat list from: $baseUrl/chats');

      final response = await http.get(
        Uri.parse('$baseUrl/chats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(milliseconds: Config.connectTimeout),
        onTimeout: () {
          debugPrint('Request timeout - server not responding');
          throw Exception('Connection timeout');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final chatsList = data['data']['chats'] as List;
          debugPrint('Successfully fetched ${chatsList.length} chats');
          return chatsList.map((chat) => ChatModel.fromJson(chat)).toList();
        } else {
          debugPrint('Unexpected response format: $data');
          return null;
        }
      } else if (response.statusCode == 401) {
        debugPrint('Unauthorized - token may be invalid');
        return null;
      } else if (response.statusCode == 404) {
        debugPrint('Endpoint not found - check API route');
        return null;
      } else {
        debugPrint('Server error: ${response.statusCode}');
        return null;
      }
    } on SocketException catch (e) {
      debugPrint('Network error: ${e.message}');
      debugPrint('Check if server is running and device has internet');
      return null;
    } on HttpException catch (e) {
      debugPrint('HTTP error: ${e.message}');
      return null;
    } on FormatException catch (e) {
      debugPrint('JSON parse error: ${e.message}');
      debugPrint('Response may not be valid JSON');
      return null;
    } on TimeoutException catch (e) {
      debugPrint('Timeout error: ${e.message}');
      debugPrint('Server took too long to respond');
      return null;
    } catch (e, stackTrace) {
      debugPrint('Unexpected error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<Chat?> initiateChat(int orderId,
      {int? customerId, int? courierId}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final Map<String, dynamic> body = {
        'order_id': orderId,
      };

      if (customerId != null) {
        body['recipient_id'] = customerId;
        body['recipient_type'] = 'USER';
      } else if (courierId != null) {
        body['courier_id'] = courierId;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/chat/initiate'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(Duration(seconds: Config.connectTimeout));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Chat.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('Error initiating chat: $e');
      return null;
    }
  }

  Future<Chat?> initiateChatWithTransaction(int orderId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        debugPrint('initiateChatWithTransaction: No auth token');
        return null;
      }

      // Get current merchant ID from auth service
      final merchant = _authService.currentUser.value?.merchant;
      final merchantId = merchant?.id;
      
      debugPrint('initiateChatWithTransaction: Initiating chat with order_id: $orderId, merchant_id: $merchantId');

      final body = <String, dynamic>{
        'order_id': orderId,
      };
      
      // Add merchant_id if available
      if (merchantId != null) {
        body['merchant_id'] = merchantId;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/chat/initiate'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode(body),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('initiateChatWithTransaction: Request timeout');
              throw Exception('Request timeout');
            },
          );

      debugPrint('initiateChatWithTransaction: Response status: ${response.statusCode}');
      debugPrint('initiateChatWithTransaction: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          debugPrint('initiateChatWithTransaction: SUCCESS - Chat ID: ${data['data']['id']}');
          return Chat.fromJson(data['data']);
        }
      }
      
      debugPrint('initiateChatWithTransaction: Failed - ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('initiateChatWithTransaction: Exception: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getChatDetails(int chatId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/chat/$chatId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: Config.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final chatData = data['data'];
          return {
            'recipientName': chatData['recipient_name'] ?? 'Chat',
            'recipientType': chatData['recipient_type'] ?? '',
            'recipientAvatar': chatData['recipient_avatar'] ?? '',
            'status': chatData['status'] ?? 'ACTIVE',
          };
        }
      }
      return null;
    } catch (e) {
      print('Error fetching chat details: $e');
      return null;
    }
  }

  Future<ChatMessage?> sendMessage(int chatId,
      {String? message, File? image}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      // Handle image upload via multipart
      if (image != null) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/chat/$chatId/send'),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept'] = 'application/json';
        
        // Add image file
        var imageFile = await http.MultipartFile.fromPath(
          'attachment',
          image.path,
        );
        request.files.add(imageFile);
        
        // Add optional message
        if (message != null && message.isNotEmpty) {
          request.fields['message'] = message;
        }

        var streamedResponse = await request.send().timeout(
          Duration(seconds: Config.connectTimeout),
        );
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            return ChatMessage.fromJson(data['data']);
          }
        }
        return null;
      }

      // Handle text message
      if (message != null) {
        final response = await http
            .post(
              Uri.parse('$baseUrl/chat/$chatId/send'),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'message': message,
              }),
            )
            .timeout(Duration(seconds: Config.connectTimeout));

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['data'] != null) {
            return ChatMessage.fromJson(data['data']);
          }
        }
      }
      return null;
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }

  /// Share location via chat
  Future<ChatMessage?> shareLocation(int chatId, {
    required double latitude,
    required double longitude,
    double? locationAccuracy,
    String? locationAddress,
    String? locationName,
    String? message,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http
          .post(
            Uri.parse('$baseUrl/chat/$chatId/share-location'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'latitude': latitude,
              'longitude': longitude,
              if (locationAccuracy != null) 'location_accuracy': locationAccuracy,
              if (locationAddress != null) 'location_address': locationAddress,
              if (locationName != null) 'location_name': locationName,
              if (message != null) 'message': message,
            }),
          )
          .timeout(Duration(seconds: Config.connectTimeout));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ChatMessage.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error sharing location: $e');
      return null;
    }
  }

  Future<List<ChatMessage>?> getMessages(int chatId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/chat/$chatId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: Config.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true &&
            data['data'] != null &&
            data['data']['messages'] != null) {
          final messagesList = data['data']['messages'] as List;
          return messagesList.map((m) => ChatMessage.fromJson(m)).toList();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching messages: $e');
      return null;
    }
  }

  Future<void> markChatAsRead(int chatId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return;

      await http.put(
        Uri.parse('$baseUrl/chat/$chatId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: Config.connectTimeout));
    } catch (e) {
      print('Error marking chat as read: $e');
    }
  }

  Future<Map<String, dynamic>?> getOrderData(int orderId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: Config.connectTimeout));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final orderData = data['data'];
          return {
            'customerName': orderData['customer_name'] ?? 'Pelanggan',
            'customerAvatar': orderData['customer_avatar'] ?? '',
            'customerPhone': orderData['customer_phone'] ?? '',
          };
        }
      }
      return null;
    } catch (e) {
      print('Error fetching order data: $e');
      return null;
    }
  }
}
