import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:antarkanma_merchant/app/controllers/theme_controller.dart';
import '../controllers/chat_list_controller.dart';
import 'widgets/chat_list_tile.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage>
    with WidgetsBindingObserver {
  final controller = Get.put(ChatListController());
  final themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.fetchChats(); // Immediate fetch on open
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes to foreground
      debugPrint('App resumed, refreshing chat list');
      controller.fetchChats();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.themeMode.value == ThemeMode.dark;
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          title: Text(
            'Chat Saya',
            style: primaryTextStyle.copyWith(
              fontSize: 20,
              fontWeight: semiBold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          centerTitle: true,
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          elevation: 0,
        ),
          body: controller.isLoading.value && controller.chats.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(logoColorSecondary),
                  ),
                )
              : controller.chats.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () => controller.refresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: controller.chats.length,
                        itemBuilder: (context, index) {
                          final chat = controller.chats[index];
                          return ChatListTile(chat: chat);
                        },
                      ),
                    ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Get.isDarkMode ? AppColors.darkTextHint : AppColors.lightTextHint,
          ),
          SizedBox(height: 24),
          Text(
            'Belum Ada Chat',
            style: primaryTextStyle.copyWith(
              fontSize: 18,
              fontWeight: semiBold,
              color: Get.isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Mulai chat dengan merchant atau kurir dari halaman pesanan Anda',
              style: secondaryTextStyle.copyWith(
                fontSize: 14,
                color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
