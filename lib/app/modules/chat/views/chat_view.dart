import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:antarkanma_merchant/app/data/models/chat_model.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: chatBackgroundLight,
      body: Stack(
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
                        valueColor:
                            AlwaysStoppedAnimation<Color>(chatSecondary),
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
                              color: chatTextSecondary.withOpacity(0.5)),
                          SizedBox(height: 16),
                          Text(
                            "Belum ada pesan. Mulai obrolan!",
                            style: secondaryTextStyle.copyWith(
                                color: chatTextSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: EdgeInsets.only(
                      top: 16,
                      bottom: 180, // Space for input area + quick replies
                      left: 16,
                      right: 16,
                    ),
                    reverse: true, // Show newest messages at bottom
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
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
                          if (showDateSeparator)
                            _buildDateSeparator(message.createdAt),
                          _buildMessageBubble(message, isMe),
                        ],
                      );
                    },
                  );
                }),
              ),
            ],
          ),

          // Bottom Input Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildInputArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
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
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 20, color: chatTextSecondary),
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
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: chatTextDark,
                                    ),
                                  ),
                                  Text(
                                    _getRecipientSubtitle(),
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                      color: chatTextSecondary,
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
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.call, color: chatPrimary, size: 20),
                    ),
                  ],
                ),
              ),
              // Status Bar - Only show for courier chat
              Obx(() {
                // Don't show status bar for customer chat
                if (controller.recipientType.value == 'CUSTOMER') {
                  return const SizedBox.shrink();
                }

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: chatSecondary.withOpacity(0.1),
                    border: Border(
                        top: BorderSide(color: chatSecondary.withOpacity(0.2))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.moped, size: 16, color: chatSecondary),
                          SizedBox(width: 8),
                          Text(
                            _getStatusText(),
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "LIHAT PETA",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: chatSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
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
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: chatTextSecondary,
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
      return '${messageDate.day.toString().padLeft(2, '0')} ${monthName} ${messageDate.year}';
    } catch (e) {
      return 'HARI INI'; // Fallback
    }
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: Get.width * 0.85),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isMe ? chatPrimary : chatBubbleMerchant,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: isMe ? Radius.circular(16) : Radius.circular(0),
                    bottomRight:
                        isMe ? Radius.circular(0) : Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                  border: isMe ? null : Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Message
                    if (message.isImage && message.attachmentUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message.attachmentUrl!,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[200],
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey[200],
                              child: Center(
                                child: Icon(Icons.image_not_supported, size: 40),
                              ),
                            );
                          },
                        ),
                      ),
                    
                    // Location Message
                    if (message.isLocation && message.latitude != null)
                      _buildLocationMessage(message, isMe),
                    
                    // Text Message
                    if (message.message != null && message.message!.isNotEmpty)
                      Text(
                        message.message!,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: isMe ? Colors.white : chatTextDark,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 4),
            // Timestamp
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: chatTextSecondary,
                fontSize: 10,
              ),
            ),
            if (isMe) ...[
              SizedBox(width: 2),
              Icon(Icons.done_all,
                  size: 14, color: message.isRead ? Colors.blue : Colors.grey),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMessage(ChatMessage message, bool isMe) {
    final locationName = message.locationName ?? 'Lokasi';
    final accuracy = message.locationAccuracy != null 
        ? '±${message.locationAccuracy!.toStringAsFixed(1)}m' 
        : '';
    
    return GestureDetector(
      onTap: () {
        // Open Google Maps
        final url = message.googleMapsUrl;
        if (url != null) {
          launchUrl(Uri.parse(url));
        }
      },
      child: Container(
        width: 200,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: isMe ? Colors.white : Colors.red,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationName,
                    style: TextStyle(
                      color: isMe ? Colors.white : chatTextDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (accuracy.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                'Akurasi: $accuracy',
                style: TextStyle(
                  color: isMe ? Colors.white.withOpacity(0.8) : chatTextSecondary,
                  fontSize: 11,
                ),
              ),
            ],
            if (message.locationAddress != null) ...[
              SizedBox(height: 4),
              Text(
                message.locationAddress!,
                style: TextStyle(
                  color: isMe ? Colors.white.withOpacity(0.8) : chatTextSecondary,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Buka di Maps',
                  style: TextStyle(
                    color: isMe ? Colors.white : chatSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  size: 12,
                  color: isMe ? Colors.white : chatSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick Replies - Merchant specific (mostly chat with customer)
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

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: quickReplies.map((text) => Padding(
                padding: EdgeInsets.only(right: 8),
                child: _buildQuickReplyButton(text),
              )).toList(),
            ),
          );
        }),

        // Input Field
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_circle, color: chatTextSecondary),
                onPressed: () {
                  controller.showAttachmentOptions();
                },
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: chatBackgroundLight,
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
                              color: chatTextSecondary,
                            ),
                            border: InputBorder.none,
                          ),
                          minLines: 1,
                          maxLines: 4,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: chatTextDark,
                          ),
                        ),
                      ),
                      Icon(Icons.mood, color: chatTextSecondary),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Obx(() => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: chatPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: controller.isSending.value
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: controller.isSending.value
                          ? null
                          : controller.sendMessage,
                    ),
                  )),
            ],
          ),
        ),
      ],
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: chatTextDark,
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
