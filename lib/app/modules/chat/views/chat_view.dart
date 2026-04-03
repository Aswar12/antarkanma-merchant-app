// ignore_for_file: unused_element

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:antarkanma_merchant/app/data/models/chat_model.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:antarkanma_merchant/app/widgets/chat_bubble_location.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Get.isDarkMode ? AppColors.darkBackground : Colors.white,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Layer 1: Base Background
            Positioned.fill(
              child: Container(
                color: Get.isDarkMode ? AppColors.darkBackground : Colors.white,
              ),
            ),

            // Layer 2: Pattern Asset
            Positioned.fill(
              child: Opacity(
                opacity: Get.isDarkMode ? 0.08 : 0.25,
                child: Image.asset(
                  Get.isDarkMode
                      ? 'assets/bg_chatpage.png'
                      : 'assets/bg_chatlightmode.png',
                  fit: BoxFit.cover,
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),

            // Layer 3: Content
            Positioned.fill(
              child: _buildChatContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatContent() {
    return Stack(
      children: [
        Column(
          children: [
            // Custom Header + Status Bar
            _buildHeader(),

            // Chat Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.chatAccent),
                    ),
                  );
                }

                if (controller.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48,
                            color: AppColors.chatTextSecondaryLight.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada pesan. Mulai obrolan!",
                          style: secondaryTextStyle.copyWith(
                              color: AppColors.chatTextSecondaryLight),
                        ),
                      ],
                    ),
                  );
                }

                // Add loading indicator at top when loading more
                final showLoadingAtTop =
                    controller.hasMorePages && controller.isLoadingMore.value;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                    final isKeyboardVisible = keyboardHeight > 0;
                    // Calculate bottom padding: when keyboard is visible, reduce padding
                    final bottomPadding = isKeyboardVisible ? 100.0 : 180.0;

                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        // Load more messages when scrolling to top
                        if (notification is ScrollEndNotification &&
                            !controller.isLoadingMore.value &&
                            controller.hasMorePages) {
                          // Check if scrolled near top (within 200px threshold)
                          if (notification.metrics.pixels < 200.0) {
                            controller.loadMoreMessages();
                          }
                        }
                        return false;
                      },
                      child: ListView.builder(
                        controller: controller.scrollController,
                        padding: EdgeInsets.only(
                          top: 16,
                          bottom: bottomPadding, // Space for input area + quick replies
                          left: 16,
                          right: 16,
                        ),
                        reverse: true, // Show newest messages at bottom
                        itemCount: controller.messages.length +
                            (controller.hasMorePages ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Show loading indicator at top when loading more
                          if (index == controller.messages.length &&
                              controller.hasMorePages) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.chatAccent),
                                ),
                              ),
                            );
                          }

                          final message = controller.messages[index];
                          final bool isMe =
                              message.senderId == controller.currentUserId;

                          // Show date separator at the LAST message of each day (oldest message of that day)
                          // This ensures the badge stays in place and doesn't move when new messages arrive
                          bool showDateSeparator = false;

                          // Check if this is the LAST message of its day (next message is from different day)
                          if (index == controller.messages.length - 1) {
                            // Last item in list (oldest message) always show date separator
                            showDateSeparator = true;
                          } else {
                            // Check if next message is from a different day
                            final nextDate = DateTime.parse(
                                    controller.messages[index + 1].createdAt)
                                .toLocal();
                            final currDate =
                                DateTime.parse(message.createdAt).toLocal();
                            // If next message is from different day, this is the last message of current day
                            if (nextDate.year != currDate.year ||
                                nextDate.month != currDate.month ||
                                nextDate.day != currDate.day) {
                              showDateSeparator = true;
                            }
                          }

                          return Column(
                            children: [
                              if (showDateSeparator && !showLoadingAtTop)
                                _buildDateSeparator(message.createdAt),
                              _buildMessageBubble(message, isMe),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),

        // Bottom Input Area - Now handles keyboard automatically
        _buildInputArea(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navy,
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  height: MediaQuery.of(Get.context!).padding.top), // Safe Area
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 20, color: Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade200,
                                ),
                                child: ClipOval(
                                  child: Obx(() {
                                    final avatar =
                                        controller.recipientAvatar.value;
                                    if (avatar.isNotEmpty) {
                                      return Image.network(
                                        avatar,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.person,
                                              color: Colors.grey);
                                        },
                                      );
                                    }
                                    return Icon(Icons.person,
                                        color: Colors.grey);
                                  }),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 12),
                          Obx(() => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.recipientName.value,
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _getRecipientSubtitle(),
                                    style: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.call, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRecipientSubtitle() {
    final type = controller.recipientType.value;
    switch (type) {
      case 'CUSTOMER':
        return 'Customer';
      case 'COURIER':
        return 'Kurir Antarkanma';
      default:
        return 'Chat';
    }
  }

  String _getStatusText() {
    final status = controller.chatStatus.value;
    switch (status.toUpperCase()) {
      case 'IDLE':
        return 'Menunggu Pekerjaan';
      case 'DELIVERING':
        return 'Sedang Mengantar';
      case 'PICKING_UP':
        return 'Menjemput Pesanan';
      default:
        return 'Tersedia';
    }
  }

  Widget _buildDateSeparator(String timestamp) {
    final label = _getDateLabel(timestamp);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Get.isDarkMode
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: Get.isDarkMode ? Colors.white70 : AppColors.chatTextSecondaryLight,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  String _getDateLabel(String timestamp) {
    try {
      final messageDate = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now().toLocal();
      final yesterday = now.subtract(const Duration(days: 1));

      // Check if today
      if (messageDate.year == now.year &&
          messageDate.month == now.month &&
          messageDate.day == now.day) {
        return 'HARI INI';
      }

      // Check if yesterday
      if (messageDate.year == yesterday.year &&
          messageDate.month == yesterday.month &&
          messageDate.day == yesterday.day) {
        return 'KEMARIN';
      }

      // Otherwise, return formatted date (e.g., "01 Mar 2026")
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final monthName = months[messageDate.month - 1];
      return '${messageDate.day.toString().padLeft(2, '0')} $monthName ${messageDate.year}';
    } catch (e) {
      return 'HARI INI'; // Fallback
    }
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) const SizedBox(width: 4),
            Flexible(
              child: GestureDetector(
                onLongPress:
                    isMe ? () => _showDeleteMessageDialog(message) : null,
                child: Container(
                  padding: EdgeInsets.all(message.isImage ? 0 : 8),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.navy
                        : (Get.isDarkMode
                            ? const Color(0xFF202C33)
                            : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft:
                          isMe ? const Radius.circular(12) : const Radius.circular(0),
                      bottomRight:
                          isMe ? const Radius.circular(0) : const Radius.circular(12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    border: isMe
                        ? Border.all(color: Colors.transparent, width: 0)
                        : Border.all(
                            color: Get.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade200,
                            width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message Text with integrated timestamp
                      if (message.message != null &&
                          message.message!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.end,
                            children: [
                              Text(
                                message.message!,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: (isMe || Get.isDarkMode)
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatTime(message.createdAt),
                                      style: TextStyle(
                                        color: (isMe || Get.isDarkMode)
                                            ? Colors.white60
                                            : Colors.black54,
                                        fontSize: 10,
                                      ),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.done_all,
                                        size: 14,
                                        color: message.isRead
                                            ? const Color(0xFF53BDEB)
                                            : Colors.white60,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Image Message
                      if (message.isImage)
                        message.isSending
                            ? _buildLoadingImage()
                            : message.attachmentUrl != null
                                ? GestureDetector(
                                    onTap: () => _showFullScreenImage(
                                        message.attachmentUrl!),
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isMe
                                                  ? Colors.black.withValues(alpha: 0.15)
                                                  : (Get.isDarkMode
                                                      ? Colors.grey.shade600
                                                      : Colors.grey.shade300),
                                              width: 0.3,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              message.attachmentUrl!,
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Container(
                                                  width: 200,
                                                  height: 200,
                                                  color: Get.isDarkMode
                                                      ? Colors.grey[800]
                                                      : Colors.grey[200],
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        isMe
                                                            ? Colors.white
                                                            : AppColors.chatAccent,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: 200,
                                                  height: 200,
                                                  color: Get.isDarkMode
                                                      ? Colors.grey[800]
                                                      : Colors.grey[200],
                                                  child: const Center(
                                                    child: Icon(
                                                        Icons.image_not_supported,
                                                        size: 40,
                                                        color: Colors.grey),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        if (!message.isSending)
                                          Positioned(
                                            bottom: 4,
                                            right: 6,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.3),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _formatTime(
                                                        message.createdAt),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  if (isMe) ...[
                                                    const SizedBox(width: 4),
                                                    Icon(
                                                      Icons.done_all,
                                                      size: 14,
                                                      color: message.isRead
                                                          ? const Color(0xFF53BDEB)
                                                          : Colors.white,
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                : _buildLoadingImage(),

                      // Location Message
                      if (message.isLocation)
                        _buildLocationMessageNew(message, isMe),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMessageNew(ChatMessage message, bool isMe) {
    // Determine state based on message data
    final LocationBubbleState state;
    if (message.isSending || message.latitude == null) {
      state = LocationBubbleState.loading;
    } else if (message.latitude != null && message.longitude != null) {
      state = LocationBubbleState.success;
    } else {
      state = LocationBubbleState.error;
    }

    return ChatBubbleLocation(
      state: state,
      latitude: message.latitude,
      longitude: message.longitude,
      accuracy: message.locationAccuracy,
      locationName: message.locationName,
      address: message.locationAddress,
      isMe: isMe,
      onLocationFetch: null,
      onLocationEdited: (lat, lng, addr) {
        controller.updateLocationMessage(message, lat, lng, addr);
      },
      onOpenMaps: () {
        if (message.latitude != null && message.longitude != null) {
          final url = 'https://www.google.com/maps/search/?api=1&query=${message.latitude},${message.longitude}';
          launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        }
      },
    );
  }

  /// Build loading state for image message with shimmer effect
  Widget _buildLoadingImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          color: Get.isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey[200],
        ),
        child: Stack(
          children: [
            // Shimmer background effect
            Shimmer.fromColors(
              baseColor: Get.isDarkMode ? Colors.grey[800]! : Colors.grey.shade300,
              highlightColor: Get.isDarkMode ? Colors.grey[700]! : Colors.grey.shade100,
              period: const Duration(milliseconds: 1200),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey.shade300,
                      Colors.grey.shade200,
                      Colors.grey.shade300,
                      Colors.grey.shade200,
                    ],
                  ),
                ),
              ),
            ),
            // Center loading indicator
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with background
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.chatSentBubble.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.chatSentBubble,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Loading text
                    const Text(
                      'Mengirim...',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress indicator
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.chatSentBubble),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading state for text message with shimmer effect
  Widget _buildLoadingTextMessage({required bool isMe}) {
    // Calculate width based on message length (min 100px, max 60% of screen)
    final maxWidth = Get.width * 0.6;

    return Shimmer.fromColors(
      baseColor: isMe
          ? AppColors.chatSentBubble.withValues(alpha: 0.7)
          : Colors.grey.shade300,
      highlightColor: isMe
          ? AppColors.chatSentBubble.withValues(alpha: 0.5)
          : Colors.grey.shade100,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: maxWidth,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Show full-screen image with zoom
  void _showFullScreenImage(String imageUrl) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                value: event == null
                    ? null
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.chatAccent),
              ),
            ),
          ),
        ),
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildInputArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get keyboard height
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final isKeyboardVisible = keyboardHeight > 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick Replies - Merchant specific (only show when keyboard is visible)
            Obx(() {
              final isCustomerChat = controller.recipientType.value == 'CUSTOMER';
              final quickReplies = isCustomerChat
                  ? [
                      'Pesanan sedang disiapkan',
                      'Estimasi 15 menit',
                      'Pesanan sudah diterima',
                      'Menunggu kurir',
                      'Stok habis',
                      'Minta konfirmasi',
                      'Terima kasih',
                      'Jangan lupa review',
                    ]
                  : [
                      'Sudah sampai mana?',
                      'Sesuai aplikasi ya',
                      'Terima kasih',
                    ];

              // Show quick replies only when keyboard is visible
              if (!isKeyboardVisible) {
                return const SizedBox.shrink();
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: quickReplies
                      .map((text) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildQuickReplyButton(text),
                          ))
                      .toList(),
                ),
              );
            }),

            // Input Field
            Container(
              padding: EdgeInsets.fromLTRB(
                  8, 8, 8, isKeyboardVisible ? 8 : (Get.bottomBarHeight > 0 ? Get.bottomBarHeight : 12)),
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? Colors.black.withValues(alpha: 0.85)
                    : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Get.isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade200,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add_circle_outline,
                        color: Get.isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600),
                    onPressed: () => controller.showAttachmentOptions(),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Get.isDarkMode
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.messageController,
                              decoration: InputDecoration(
                                hintText: 'Ketik pesan...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  color: Get.isDarkMode
                                      ? Colors.grey.shade500
                                      : Colors.grey.shade400,
                                ),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                color: Get.isDarkMode ? Colors.white : Colors.black87,
                              ),
                              minLines: 1,
                              maxLines: 4,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.sentiment_satisfied_alt,
                                color: Get.isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppColors.navy,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: controller.sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteMessageDialog(ChatMessage message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Pesan'),
        content: const Text('Apakah Anda yakin ingin menghapus pesan ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // Perform deletion
              Get.back(); // Close dialog
              controller.deleteMessage(message);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplyButton(String text) {
    return InkWell(
      onTap: () {
        controller.messageController.text = text;
        controller.sendMessage();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Get.isDarkMode
              ? AppColors.navy.withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Get.isDarkMode
                ? AppColors.navy.withValues(alpha: 0.3)
                : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: Get.isDarkMode ? Colors.white : AppColors.chatTextDark,
          ),
        ),
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return '';
    }
  }
}
