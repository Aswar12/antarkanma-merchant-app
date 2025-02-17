import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double? rating;
  final double size;
  final Color? color;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 16,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double actualRating = rating ?? 0.0;
    final int fullStars = actualRating.floor();
    final bool hasHalfStar = (actualRating - fullStars) >= 0.5;
    final starColor = color ?? Colors.amber;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: starColor, size: size);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: starColor, size: size);
        } else {
          return Icon(Icons.star_border, color: starColor, size: size);
        }
      }),
    );
  }
}
