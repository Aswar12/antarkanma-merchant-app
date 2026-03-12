import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/app/data/models/chat_model.dart';
import 'package:antarkanma_merchant/app/data/repositories/chat_repository.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:geolocator/geolocator.dart';

class ChatController extends GetxController with WidgetsBindingObserver {
  final ChatRepository _repository = ChatRepository();
  final AuthService _authService = Get.find<AuthService>();

  final messages = <ChatMessage>[].obs;
  final isLoading = false.obs;
  final isSending = false.obs;
  final isLoadingMore = false.obs; // For pagination

  // Pagination state
  int currentPage = 1;
  int lastPage = 1;
  bool hasMorePages = false;
  bool isLoadingAllMessages = false;
  static const int perPage = 50;

  // Recipient info
  final RxString recipientName = 'Chat'.obs;
  final RxString recipientType = ''.obs; // CUSTOMER, COURIER
  final RxString recipientAvatar = ''.obs;
  final RxString chatStatus = ''.obs;

  final messageController = TextEditingController();
  final scrollController = ScrollController();

  int? chatId;
  int? orderId;
  int? recipientId;

  // Retrieve current user ID
  int get currentUserId => _authService.currentUser.value?.id ?? 0;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    final args = Get.arguments;
    if (args != null) {
      if (args['orderId'] != null) {
        orderId = args['orderId'];
        chatId = args['chatId']; // This will be null initially for new chats

        _startChatSession();
      } else if (args['chatId'] != null) {
        // Handle navigation from Chat List
        chatId = args['chatId'];
        orderId = args['orderId'];
        _startChatSession();
      }
    }
  }

  void _startChatSession() async {
    try {
      if (orderId != null && chatId == null) {
        // Initiate chat with customer
        await _initiateChatWithCustomer();
      }

      if (chatId != null) {
        // Load recipient info
        await _loadRecipientInfo();

        _fetchMessages(initial: true);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memulai sesi chat: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: alertColor.withOpacity(0.8),
        colorText: Colors.white,
      );
      Get.back();
    }
  }

  Future<void> _initiateChatWithCustomer() async {
    if (orderId == null) {
      Get.snackbar(
        'Error',
        'Data order tidak lengkap',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: alertColor.withOpacity(0.8),
        colorText: Colors.white,
      );
      Get.back();
      return;
    }

    isLoading.value = true;
    try {
      final chat = await _repository.initiateChatWithTransaction(orderId!);
      isLoading.value = false;

      if (chat?.id != null) {
        chatId = chat!.id;
        recipientId = chat!.customerId;

        // Load customer name from order data
        await _loadCustomerInfo();

        _fetchMessages(initial: true);
      } else {
        Get.snackbar(
          'Error',
          'Gagal memulai chat dengan pelanggan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: alertColor.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        Get.back();
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: alertColor.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      Get.back();
    }
  }

  Future<void> _loadCustomerInfo() async {
    if (orderId == null) return;

    try {
      // Get order data to find customer info
      final orderData = await _repository.getOrderData(orderId!);

      if (orderData != null) {
        recipientName.value = orderData['customerName'] ?? 'Pelanggan';
        recipientType.value = 'CUSTOMER';
        recipientAvatar.value = orderData['customerAvatar'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading customer info: $e');
      // Use default value if failed to load
      recipientName.value = 'Pelanggan';
      recipientType.value = 'CUSTOMER';
    }
  }

  Future<void> _loadRecipientInfo() async {
    if (chatId == null) return;

    try {
      // Get chat details from repository
      final chatDetails = await _repository.getChatDetails(chatId!);

      if (chatDetails != null) {
        recipientName.value = chatDetails['recipientName'] ?? 'Chat';
        recipientType.value = chatDetails['recipientType'] ?? '';
        recipientAvatar.value = chatDetails['recipientAvatar'] ?? '';
        chatStatus.value = chatDetails['status'] ?? '';
      }
    } catch (e) {
      debugPrint('Error loading recipient info: $e');
      // Use default values if failed to load
      recipientName.value = 'Chat';
      recipientType.value = '';
    }
  }

  Future<void> _fetchMessages({bool initial = false, bool loadMore = false}) async {
    if (chatId == null) return;

    if (initial) {
      isLoading.value = true;
      currentPage = 1;
      messages.clear();
    }

    if (loadMore) {
      if (!hasMorePages || isLoadingMore.value) return;
      isLoadingMore.value = true;
      currentPage++;
    }

    try {
      final paginatedMessages = await _repository.getMessages(
        chatId!,
        page: currentPage,
        perPage: perPage,
      );

      if (paginatedMessages != null) {
        final newMessages = paginatedMessages.messages;

        if (initial || !loadMore) {
          // Backend returns messages in ascending order: [oldest, ..., newest]
          // ListView with reverse: true displays:
          //   - First item (oldest) at bottom
          //   - Last item (newest) at top
          // So we need to reverse the list to get correct display order:
          //   - After reverse: [newest, ..., oldest]
          //   - With reverse: true → newest at bottom, oldest at top ✓
          messages.assignAll(newMessages.reversed.toList());
        } else if (loadMore) {
          // Insert older messages at the end (bottom of reversed list)
          // These are older messages, so they go after the current messages
          final olderMessages = newMessages.reversed.toList();
          messages.addAll(olderMessages);
        }

        // Update pagination state
        currentPage = paginatedMessages.currentPage;
        lastPage = paginatedMessages.lastPage;
        hasMorePages = paginatedMessages.hasMorePages;

        debugPrint(
            '_fetchMessages: Loaded page $currentPage of $lastPage, hasMore: $hasMorePages');

        // Scroll to show newest messages at bottom
        if (initial || !loadMore) {
          scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('_fetchMessages error: $e');
    } finally {
      if (initial) isLoading.value = false;
      if (loadMore) isLoadingMore.value = false;
    }
  }

  Future<void> refreshMessages() async {
    // Reset pagination and fetch first page
    currentPage = 1;
    hasMorePages = true;
    await _fetchMessages(initial: true);
  }

  /// Load older messages (pagination)
  Future<void> loadMoreMessages() async {
    await _fetchMessages(loadMore: true);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground, refresh chat
      if (chatId != null) {
        refreshMessages();
      }
    }
  }

  void scrollToBottom() {
    // Use post frame callback to ensure ListView is built before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        // With reverse: true and reversed list [newest, ..., oldest]:
        // minScrollExtent shows newest messages (at bottom)
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    if (chatId == null || messageController.text.trim().isEmpty) return;

    final text = messageController.text;
    messageController.clear();

    // Optimistic UI Update (Locally prepend message)
    final optimisticMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      chatId: chatId!,
      senderId: currentUserId,
      message: text,
      type: 'TEXT',
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
    );
    // FIX: Use insert(0, ...) instead of add() because ListView has reverse: true
    // With reverse: true, first item in list appears at bottom (newest message position)
    messages.insert(0, optimisticMessage);
    scrollToBottom();

    isSending.value = true;

    // Send to Backend (MySQL + triggers FCM automatically)
    final newMessage = await _repository.sendMessage(chatId!, message: text);

    if (newMessage != null) {
      // Wait for the next poll or force fetch to ensure IDs are correct
      _fetchMessages();
    } else {
      Get.snackbar("Error", "Gagal mengirim pesan");
      messages.remove(optimisticMessage); // Revert optimistic update
    }

    isSending.value = false;
  }

  Future<void> sendImage() async {
    if (chatId == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      isSending.value = true;

      // Show loading indicator
      Get.dialog(
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(chatSecondary),
          ),
        ),
        barrierDismissible: false,
      );

      try {
        final newMessage =
            await _repository.sendMessage(chatId!, image: File(image.path));

        Get.back(); // Close loading dialog

        if (newMessage != null) {
          _fetchMessages();
          scrollToBottom();
        } else {
          Get.snackbar("Error", "Gagal mengirim gambar");
        }
      } catch (e) {
        Get.back(); // Close loading dialog
        Get.snackbar("Error", "Gagal mengirim gambar: ${e.toString()}");
      } finally {
        isSending.value = false;
      }
    }
  }

  /// Share current location
  Future<void> shareLocation() async {
    if (chatId == null) return;

    try {
      // Show loading indicator
      Get.dialog(
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(chatSecondary),
              ),
              SizedBox(height: 16),
              Text(
                'Mengambil lokasi...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.back(); // Close loading dialog
          Get.snackbar(
            'Permission Denied',
            'Lokasi tidak dapat diakses tanpa izin',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Permission Denied',
          'Silakan aktifkan lokasi di pengaturan',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Get current location with high accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      Get.back(); // Close loading dialog

      // Confirm before sending
      bool? confirm = await Get.dialog(
        AlertDialog(
          title: Text('Kirim Lokasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Akurasi: ±${position.accuracy.toStringAsFixed(1)} meter'),
              SizedBox(height: 8),
              Text(
                'Lat: ${position.latitude.toStringAsFixed(6)}\nLng: ${position.longitude.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: Text('Kirim'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      isSending.value = true;

      final newMessage = await _repository.shareLocation(
        chatId!,
        latitude: position.latitude,
        longitude: position.longitude,
        locationAccuracy: position.accuracy,
        message: '📍 Lokasi saya saat ini',
      );

      if (newMessage != null) {
        _fetchMessages();
        scrollToBottom();
      } else {
        Get.snackbar("Error", "Gagal berbagi lokasi");
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal berbagi lokasi: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSending.value = false;
    }
  }

  /// Show attachment options bottom sheet
  void showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kirim Media',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.image,
                  label: 'Gambar',
                  color: chatSecondary,
                  onTap: () {
                    Get.back();
                    sendImage();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.location_on,
                  label: 'Lokasi',
                  color: Colors.red,
                  onTap: () {
                    Get.back();
                    shareLocation();
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
