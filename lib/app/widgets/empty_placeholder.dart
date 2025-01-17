import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/theme.dart';

class EmptyPlaceholder extends StatelessWidget {
  final String imagePath;
  final String title;
  final String? subtitle;
  final VoidCallback? onRefresh;

  const EmptyPlaceholder({
    Key? key,
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RefreshIndicator(
        onRefresh: () async {
          if (onRefresh != null) {
            onRefresh!();
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: EdgeInsets.all(Dimenssions.width16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image with error handling
                Container(
                  width: Dimenssions.width80,
                  height: Dimenssions.width80,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: Dimenssions.width80,
                        height: Dimenssions.width80,
                        decoration: BoxDecoration(
                          color: backgroundColor3,
                          borderRadius: BorderRadius.circular(Dimenssions.radius8),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          color: subtitleColor,
                          size: Dimenssions.width40,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: Dimenssions.height20),
                Text(
                  title,
                  style: primaryTextStyle.copyWith(
                    fontSize: Dimenssions.font18,
                    fontWeight: semiBold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: Dimenssions.height8),
                  Text(
                    subtitle!,
                    style: secondaryTextStyle.copyWith(
                      fontSize: Dimenssions.font14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (onRefresh != null) ...[
                  SizedBox(height: Dimenssions.height20),
                  TextButton.icon(
                    onPressed: onRefresh,
                    icon: Icon(
                      Icons.refresh,
                      color: logoColorSecondary,
                    ),
                    label: Text(
                      'Refresh',
                      style: primaryTextStyle.copyWith(
                        color: logoColorSecondary,
                        fontWeight: medium,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
