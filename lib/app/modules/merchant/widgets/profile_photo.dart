import 'package:flutter/material.dart';
import '../../../../theme.dart';

class ProfilePhoto extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;

  const ProfilePhoto({
    Key? key,
    this.photoUrl,
    required this.name,
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimenssions.radius12),
      child: Image.network(
        photoUrl ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor3,
            borderRadius: BorderRadius.circular(Dimenssions.radius12),
          ),
          child: Icon(
            Icons.person,
            color: subtitleColor,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
