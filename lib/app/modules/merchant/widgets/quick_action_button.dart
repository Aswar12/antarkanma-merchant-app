import 'package:flutter/material.dart';
import '../../../../theme.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: Dimenssions.width80,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(Dimenssions.height12),
              decoration: BoxDecoration(
                color: logoColorSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimenssions.radius8),
              ),
              child: Icon(
                icon,
                color: logoColorSecondary,
                size: Dimenssions.height24,
              ),
            ),
            SizedBox(height: Dimenssions.height8),
            Text(
              label,
              style: primaryTextStyle.copyWith(
                fontSize: Dimenssions.font12,
                fontWeight: medium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
