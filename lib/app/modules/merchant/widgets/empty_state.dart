import 'package:flutter/material.dart';
import '../../../../theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimenssions.height32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: Dimenssions.height80,
            color: logoColorSecondary.withOpacity(0.5),
          ),
          SizedBox(height: Dimenssions.height16),
          Text(
            'Belum Ada Pesanan',
            style: primaryTextStyle.copyWith(
              fontSize: Dimenssions.font18,
              fontWeight: semiBold,
            ),
          ),
          SizedBox(height: Dimenssions.height8),
          Text(
            'Pesanan baru akan muncul di sini',
            style: secondaryTextStyle.copyWith(
              fontSize: Dimenssions.font14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
