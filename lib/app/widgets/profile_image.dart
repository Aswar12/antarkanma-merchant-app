import 'package:antarkanma_merchant/app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileImage extends StatelessWidget {
  final UserModel user;
  final double size;
  final Color primaryColor;

  const ProfileImage({
    super.key,
    required this.user,
    this.size = 50,
    this.primaryColor = const Color(0xFF7F9CF5),
  });

  bool get isUIAvatar {
    if (user.profilePhotoUrl == null) return true;
    return user.profilePhotoUrl!.contains('ui-avatars.com');
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
            ? Image.asset(
                'assets/image_profile.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(
                    _getInitials(),
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: size * 0.4,
                    ),
                  ),
                ),
              )
            : CachedNetworkImage(
                imageUrl: user.profilePhotoUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/image_profile.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
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
      ),
    );
  }

  String _getInitials() {
    final nameParts = user.name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0].isNotEmpty ? nameParts[0][0] : ''}${nameParts[1].isNotEmpty ? nameParts[1][0] : ''}'
          .toUpperCase();
    }
    return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '';
  }
}
