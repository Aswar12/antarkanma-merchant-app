import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:antarkanma_merchant/app/controllers/auth_controller.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return AlertDialog(
      title: Text(
        'Konfirmasi Logout',
        style: primaryTextStyle.copyWith(
          fontSize: 18,
          fontWeight: semiBold,
        ),
      ),
      content: Text(
        'Apakah Anda yakin ingin keluar?',
        style: subtitleTextStyle.copyWith(
          fontSize: 14,
        ),
      ),
      backgroundColor: backgroundColor3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Cancel Button
            SizedBox(
              width: 100,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Get.back(),
                child: Text(
                  'Batal',
                  style: primaryTextStyle.copyWith(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            // Logout Button
            SizedBox(
              width: 100,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: logoColorSecondary,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  authController.logout();
                },
                child: Text(
                  'Keluar',
                  style: textwhite.copyWith(
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
