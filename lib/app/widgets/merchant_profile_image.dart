import 'package:antarkanma_merchant/app/data/models/merchant_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MerchantProfileImage extends StatelessWidget {
  final MerchantModel merchant;
  final double size;
  final Color primaryColor;

  const MerchantProfileImage({
    super.key,
    required this.merchant,
    this.size = 50,
    this.primaryColor = const Color(0xFF7F9CF5),
  });

  bool get isUIAvatar {
    if (merchant.logo == null) return true;
    return merchant.logo!.contains('ui-avatars.com');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isUIAvatar ? const Color(0xFFEBF4FF) : null,
      ),
      child: ClipOval(
        child: isUIAvatar
            ? Center(
                child: Text(
                  _getInitials(),
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: size * 0.4,
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: merchant.logo ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    _getInitials(),
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: size * 0.4,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  String _getInitials() {
    final nameParts = merchant.name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0].isNotEmpty ? nameParts[0][0] : ''}${nameParts[1].isNotEmpty ? nameParts[1][0] : ''}'
          .toUpperCase();
    }
    return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '';
  }
}
