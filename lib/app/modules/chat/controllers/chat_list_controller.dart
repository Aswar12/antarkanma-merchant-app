import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/data/models/chat_model.dart';
import 'package:antarkanma_merchant/app/data/repositories/chat_repository.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
// Use string literal for chat route

class ChatListController extends GetxController {
  final ChatRepository _repository = ChatRepository();
  final AuthService _authService = Get.find<AuthService>();

  final chats = <ChatModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChats();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> fetchChats() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final chatList = await _repository.getChatList();

      if (chatList != null) {
        chats.assignAll(chatList);
      } else {
        chats.clear();
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat chat: ${e.toString()}';
      chats.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToChat(ChatModel chat) {
    Get.toNamed('/chat/${chat.id}', arguments: {
      'chatId': chat.id,
      'orderId': chat.orderId,
      'recipientName': chat.recipientName,
    });
  }

  int getTotalUnreadCount() {
    return chats.fold(0, (sum, chat) => sum + (chat.unreadCount ?? 0));
  }

  Future<void> markAsRead(int chatId) async {
    try {
      await _repository.markChatAsRead(chatId);
      // Update local state
      final chatIndex = chats.indexWhere((c) => c.id == chatId);
      if (chatIndex != -1) {
        chats[chatIndex].unreadCount = 0;
        chats.refresh();
      }
    } catch (e) {
      debugPrint('Error marking chat as read: $e');
    }
  }

  @override
  Future<void> refresh() async {
    await fetchChats();
  }
}
