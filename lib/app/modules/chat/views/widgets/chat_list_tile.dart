import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:antarkanma_merchant/app/data/models/chat_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:antarkanma_merchant/app/controllers/theme_controller.dart';
import '../../controllers/chat_list_controller.dart';

class ChatListTile extends StatelessWidget {
  final ChatModel chat;

  const ChatListTile({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatListController>();
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.themeMode.value == ThemeMode.dark;
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: Dimenssions.width15,
          vertical: Dimenssions.height5,
        ),
        padding: EdgeInsets.all(Dimenssions.height12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(Dimenssions.radius15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => controller.navigateToChat(chat),
          borderRadius: BorderRadius.circular(Dimenssions.radius15),
          child: Row(
            children: [
              // Avatar
              if (chat.recipientAvatar != null &&
                  chat.recipientAvatar!.isNotEmpty)
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: chat.recipientAvatar!,
                    width: Dimenssions.width50,
                    height: Dimenssions.height50,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: Dimenssions.width50,
                      height: Dimenssions.height50,
                      decoration: BoxDecoration(
                        color: logoColorSecondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: logoColorSecondary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => _buildDefaultAvatar(),
                  ),
                )
              else
                _buildDefaultAvatar(),
              SizedBox(width: Dimenssions.width12),

              // Chat Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chat.recipientName,
                            style: primaryTextStyle.copyWith(
                              fontSize: Dimenssions.font14,
                              fontWeight: semiBold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: Dimenssions.width8),
                        Text(
                          _formatTime(chat.lastMessageAt),
                          style: secondaryTextStyle.copyWith(
                            fontSize: Dimenssions.font10,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimenssions.height4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessage ?? 'No messages',
                            style: secondaryTextStyle.copyWith(
                              fontSize: Dimenssions.font12,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (chat.unreadCount != null &&
                            chat.unreadCount! > 0) ...[
                          SizedBox(width: Dimenssions.width8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimenssions.width6,
                              vertical: Dimenssions.height2,
                            ),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: BoxConstraints(
                              minWidth: Dimenssions.width20,
                              minHeight: Dimenssions.height20,
                            ),
                            child: Text(
                              chat.unreadCount! > 9
                                  ? '9+'
                                  : chat.unreadCount.toString(),
                              style: primaryTextStyle.copyWith(
                                fontSize: Dimenssions.font10,
                                fontWeight: bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: Dimenssions.width50,
      height: Dimenssions.height50,
      decoration: BoxDecoration(
        color: logoColorSecondary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getIconForType(chat.recipientType),
        color: logoColorSecondary,
        size: Dimenssions.font24,
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'MERCHANT':
        return Icons.store;
      case 'COURIER':
        return Icons.delivery_dining;
      case 'USER':
        return Icons.person;
      default:
        return Icons.chat_bubble;
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return DateFormat('HH:mm').format(dateTime);
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE', 'id_ID').format(dateTime);
      } else {
        return DateFormat('dd/MM/yy').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }
}
