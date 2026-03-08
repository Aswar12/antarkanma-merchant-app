import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/theme.dart';

class EmptyInboxState extends StatelessWidget {
  const EmptyInboxState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: secondaryTextColor.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum Ada Notifikasi',
            style: primaryTextStyle.copyWith(
              fontSize: 18,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Notifikasi tentang pesanan dan aktivitas toko Anda akan muncul di sini',
              style: secondaryTextStyle.copyWith(
                fontSize: 14,
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
