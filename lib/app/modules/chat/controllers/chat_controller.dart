import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/app/data/models/chat_model.dart';
import 'package:antarkanma_merchant/app/data/repositories/chat_repository.dart';
import 'package:antarkanma_merchant/app/services/auth_service.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:antarkanma_merchant/app/services/storage_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:antarkanma_merchant/app/widgets/location_picker_dialog.dart';

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

  // Retrieve current user ID with fallback to storage
  int get currentUserId {
    final user = _authService.currentUser.value;
    if (user != null) return user.id;

    // Direct fallback to storage as a safety measure for persistent identity
    try {
      final userData = StorageService.instance.getUser();
      if (userData != null && userData['id'] != null) {
        return int.tryParse(userData['id'].toString()) ?? 0;
      }
    } catch (e) {
      debugPrint('Error getting currentUserId from storage: $e');
    }
    return 0;
  }

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
        backgroundColor: alertColor.withValues(alpha: 0.8),
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
        backgroundColor: alertColor.withValues(alpha: 0.8),
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
        recipientId = chat.customerId;

        // Load customer name from order data
        await _loadCustomerInfo();

        _fetchMessages(initial: true);
      } else {
        Get.snackbar(
          'Error',
          'Gagal memulai chat dengan pelanggan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withValues(alpha: 0.8),
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
        backgroundColor: alertColor.withValues(alpha: 0.8),
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
      isSending: true, // Show loading indicator for text messages
    );
    // FIX: Use insert(0, ...) instead of add() because ListView has reverse: true
    // With reverse: true, first item in list appears at bottom (newest message position)
    messages.insert(0, optimisticMessage);
    scrollToBottom();

    isSending.value = true;

    // Send to Backend (MySQL + triggers FCM automatically)
    final newMessage = await _repository.sendMessage(chatId!, message: text);

    if (newMessage != null) {
      // Update optimistic message with real data
      messages[0] = newMessage; // Replace first message
      scrollToBottom();
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
      // Optimistic UI: Add image message immediately with shimmer loading state
      final tempMessageId = DateTime.now().millisecondsSinceEpoch;
      final optimisticMessage = ChatMessage(
        id: tempMessageId,
        chatId: chatId!,
        senderId: currentUserId,
        message: null,
        type: 'IMAGE',
        attachmentUrl: null, // Will be updated when uploaded
        isRead: false,
        createdAt: DateTime.now().toIso8601String(),
        isSending: true, // Show loading indicator
      );

      messages.insert(0, optimisticMessage);
      scrollToBottom();

      isSending.value = true;

      try {
        final newMessage =
            await _repository.sendMessage(chatId!, image: File(image.path));

        if (newMessage != null) {
          // Replace optimistic message with real one
          messages.removeWhere((m) => m.id == tempMessageId);
          messages.insert(0, newMessage);
          // No need to _fetchMessages() - just update the single message
          scrollToBottom();
        } else {
          // Remove optimistic message on failure
          messages.removeWhere((m) => m.id == tempMessageId);
          Get.snackbar("Error", "Gagal mengirim gambar");
        }
      } catch (e) {
        // Remove optimistic message on failure
        messages.removeWhere((m) => m.id == tempMessageId);
        Get.snackbar("Error", "Gagal mengirim gambar: ${e.toString()}");
      } finally {
        isSending.value = false;
      }
    }
  }

  /// Share location using progressive, optimistic UI flow
  Future<void> shareLocation() async {
    if (chatId == null) return;

    try {
      // 1. Request/Check permissions first (this is the only blocking part, but it's fast)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Izin Ditolak',
            'Aplikasi membutuhkan izin lokasi untuk fitur ini.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: alertColor.withValues(alpha: 0.8),
            colorText: Colors.white,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Izin Ditolak Permanen',
          'Silakan aktifkan izin lokasi di pengaturan perangkat Anda.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: alertColor.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
        return;
      }

      // 2. Start optimistic location sharing (instant bubble)
      final tempMessageId = await _startLocationSharing();
      if (tempMessageId == null) return;

      // 3. Fetch location progressively in background
      _fetchLocationProgressively(tempMessageId);
      
    } catch (e) {
      debugPrint('Error initiating location share: $e');
      Get.snackbar(
        "Error",
        "Gagal memulai fitur bagi lokasi",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Create optimistic message immediately
  Future<int?> _startLocationSharing() async {
    if (chatId == null) return null;

    final tempMessageId = DateTime.now().millisecondsSinceEpoch;
    final optimisticMessage = ChatMessage(
      id: tempMessageId,
      chatId: chatId!,
      senderId: currentUserId,
      message: '📍 Membagikan lokasi...',
      type: 'LOCATION',
      latitude: null,
      longitude: null,
      locationAccuracy: null,
      locationAddress: null,
      locationName: 'Mengambil lokasi...',
      isRead: false,
      createdAt: DateTime.now().toIso8601String(),
      isSending: true,
    );

    messages.insert(0, optimisticMessage);
    scrollToBottom();
    isSending.value = true;
    
    return tempMessageId;
  }

  /// Progressive fetching flow
  Future<void> _fetchLocationProgressively(int tempMessageId) async {
    try {
      _updateLoadingStatus(tempMessageId, 'Mencari sinyal GPS...');

      // 1. Try last known position for instant preview
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        await _updateLocationBubble(tempMessageId, position, 'Akurasi: ±${position.accuracy.toStringAsFixed(0)}m');
        
        // If last known is already very accurate (< 15m), we could send, 
        // but it's safer to always wait for a fresh high-accuracy lock
      }

      // 2. Listen for high-accuracy GPS update
      _updateLoadingStatus(tempMessageId, 'Mengunci kordinat GPS...');
      await _listenForHighAccuracyPosition(tempMessageId, position);

    } catch (e) {
      debugPrint('Error in progressive fetch: $e');
      messages.removeWhere((m) => m.id == tempMessageId);
      isSending.value = false;
      Get.snackbar("Error", "Gagal mendapatkan lokasi: ${e.toString()}");
    }
  }

  Future<void> _listenForHighAccuracyPosition(int tempMessageId, Position? initialPosition) async {
    final completer = Completer<Position>();
    StreamSubscription<Position>? subscription;
    Position bestPosition = initialPosition ?? Position(
      latitude: 0, longitude: 0, timestamp: DateTime.now(), 
      accuracy: 9999, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0,
      altitudeAccuracy: 0, headingAccuracy: 0
    );

    // Timeout after 20 seconds
    final timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (!completer.isCompleted) {
        completer.complete(bestPosition);
      }
    });

    subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen(
      (position) {
        _updateLocationBubble(tempMessageId, position, 'Akurasi: ±${position.accuracy.toStringAsFixed(0)}m');
        
        if (position.accuracy < bestPosition.accuracy) {
          bestPosition = position;
        }

        // GPS Lock threshold
        if (position.accuracy < 15.0 && !completer.isCompleted) {
          completer.complete(position);
        }
      },
      onError: (e) {
        if (!completer.isCompleted) completer.complete(bestPosition);
      }
    );

    final finalPosition = await completer.future;
    timeoutTimer.cancel();
    await subscription.cancel();

    // Check if we still have poor accuracy, if so open Picker
    double finalLat = finalPosition.latitude;
    double finalLng = finalPosition.longitude;
    String? finalAddr;

    if (finalPosition.accuracy > 50 || finalPosition.latitude == 0) {
      _updateLoadingStatus(tempMessageId, 'Sesuaikan di Map...');
      
      // Get address for picker
      String? initialAddress;
      try {
        final placemarks = await placemarkFromCoordinates(finalLat, finalLng).timeout(const Duration(seconds: 2));
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          initialAddress = '${p.street}, ${p.subLocality}, ${p.locality}';
        }
      } catch (_) {}

      final result = await Get.dialog(
        LocationPickerDialog(
          initialLatitude: finalLat != 0 ? finalLat : -6.200000,
          initialLongitude: finalLng != 0 ? finalLng : 106.816666,
          initialAddress: initialAddress,
        ),
      );

      if (result != null && result is Map) {
        finalLat = result['latitude'];
        finalLng = result['longitude'];
        finalAddr = result['address'];
      } else if (finalPosition.latitude == 0) {
        // Cancelled and no position
        messages.removeWhere((m) => m.id == tempMessageId);
        isSending.value = false;
        return;
      }
    }

    await _sendLocationToBackend(tempMessageId, finalLat, finalLng, finalPosition.accuracy, finalAddr);
  }

  void _updateLoadingStatus(int tempMessageId, String status) {
    final index = messages.indexWhere((m) => m.id == tempMessageId);
    if (index != -1) {
      final m = messages[index];
      messages[index] = ChatMessage(
        id: m.id,
        chatId: m.chatId,
        senderId: m.senderId,
        message: '📍 $status',
        type: 'LOCATION',
        locationName: status,
        isRead: false,
        createdAt: m.createdAt,
        isSending: true,
      );
      messages.refresh();
    }
  }

  Future<void> _updateLocationBubble(int tempMessageId, Position position, String status) async {
    final index = messages.indexWhere((m) => m.id == tempMessageId);
    if (index != -1) {
      String? address;
      try {
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude).timeout(const Duration(seconds: 1));
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          address = '${p.street}, ${p.subLocality}, ${p.locality}';
        }
      } catch (_) {}

      final m = messages[index];
      messages[index] = ChatMessage(
        id: m.id,
        chatId: m.chatId,
        senderId: m.senderId,
        message: '📍 Lokasi Merchant',
        type: 'LOCATION',
        latitude: position.latitude,
        longitude: position.longitude,
        locationAccuracy: position.accuracy,
        locationAddress: address ?? m.locationAddress,
        locationName: status,
        isRead: false,
        createdAt: m.createdAt,
        isSending: true,
      );
      messages.refresh();
    }
  }

  Future<void> _sendLocationToBackend(int tempMessageId, double lat, double lng, double accuracy, String? address) async {
    if (chatId == null) return;

    try {
      // Re-fetch address if missing
      String? finalAddr = address;
      if (finalAddr == null) {
        try {
          final placemarks = await placemarkFromCoordinates(lat, lng).timeout(const Duration(seconds: 2));
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            finalAddr = '${p.street}, ${p.subLocality}, ${p.locality}';
          }
        } catch (_) {}
      }

      final sentMessage = await _repository.shareLocation(
        chatId!,
        latitude: lat,
        longitude: lng,
        locationAccuracy: accuracy,
        locationAddress: finalAddr,
        locationName: 'Lokasi Merchant',
        message: '📍 Berbagi lokasi merchant',
      );

      if (sentMessage != null) {
        final index = messages.indexWhere((m) => m.id == tempMessageId);
        if (index != -1) {
          messages[index] = sentMessage;
        }
      } else {
        messages.removeWhere((m) => m.id == tempMessageId);
        Get.snackbar("Error", "Gagal mengirim lokasi ke server");
      }
    } catch (e) {
      messages.removeWhere((m) => m.id == tempMessageId);
      Get.snackbar("Error", "Gagal mengirim lokasi: $e");
    } finally {
      isSending.value = false;
    }
  }

  /// Update an existing location message (refine point)
  /// Since backend doesn't support PATCH for messages, we delete and re-send
  Future<void> updateLocationMessage(ChatMessage oldMessage, double lat, double lng, String? address) async {
    if (chatId == null) return;

    try {
      // 1. Show loading
      _updateLoadingStatus(oldMessage.id, 'Memperbarui lokasi...');
      
      // 2. Delete old message
      final deleteSuccess = await _repository.deleteMessage(chatId!, oldMessage.id);
      if (!deleteSuccess) {
        Get.snackbar("Error", "Gagal menghapus pesan lokasi lama");
        return;
      }
      
      // 3. Remove locally
      messages.removeWhere((m) => m.id == oldMessage.id);
      
      // 4. Send new one
      final sentMessage = await _repository.shareLocation(
        chatId!,
        latitude: lat,
        longitude: lng,
        locationAccuracy: 5.0, // Manual adjustment is assumed accurate
        locationAddress: address,
        locationName: 'Lokasi Merchant (Diperbarui)',
        message: '📍 Lokasi merchant (Diperbarui)',
      );

      if (sentMessage != null) {
        messages.insert(0, sentMessage);
      } else {
        Get.snackbar("Error", "Gagal memperbarui lokasi");
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  /// Show attachment options bottom sheet
  void showAttachmentOptions() {
    // PRE-FETCHING: Start location permission check early
    _prefetchLocationPermission();

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Get.isDarkMode ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Get.isDarkMode ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kirim Media',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih jenis media yang ingin dikirim',
              style: TextStyle(
                fontSize: 13,
                color: Get.isDarkMode ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.image_outlined,
                  label: 'Kirim Gambar',
                  color: AppColors.chatSentBubble,
                  onTap: () {
                    Get.back();
                    sendImage();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.location_on_outlined,
                  label: 'Kirim Lokasi',
                  color: AppColors.chatAccent,
                  onTap: () {
                    Get.back();
                    shareLocation();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _prefetchLocationPermission() {
    Geolocator.checkPermission().then((permission) {
      if (permission == LocationPermission.denied) {
        Geolocator.requestPermission();
      }
    });
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Get.isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteMessage(ChatMessage message) async {
    if (chatId == null) return;

    try {
      final success = await _repository.deleteMessage(chatId!, message.id);

      if (success) {
        messages.removeWhere((m) => m.id == message.id);
        Get.snackbar(
          'Sukses',
          'Pesan berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Gagal menghapus pesan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: alertColor.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: alertColor.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }
}
