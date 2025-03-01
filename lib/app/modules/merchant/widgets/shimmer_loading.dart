import 'package:flutter/material.dart';
import '../../../../theme.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimenssions.height16,
            vertical: Dimenssions.height8,
          ),
          child: Container(
            padding: EdgeInsets.all(Dimenssions.height16),
            decoration: BoxDecoration(
              color: backgroundColor1,
              borderRadius: BorderRadius.circular(Dimenssions.radius12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerBox(width: 100, height: 20),
                    _buildShimmerBox(width: 60, height: 20),
                  ],
                ),
                SizedBox(height: Dimenssions.height12),
                _buildShimmerBox(width: 150, height: 20),
                SizedBox(height: Dimenssions.height8),
                _buildShimmerBox(width: 200, height: 20),
                SizedBox(height: Dimenssions.height12),
                _buildShimmerBox(width: 120, height: 24),
                SizedBox(height: Dimenssions.height16),
                Row(
                  children: [
                    Expanded(child: _buildShimmerBox(height: 45)),
                    SizedBox(width: Dimenssions.width12),
                    Expanded(child: _buildShimmerBox(height: 45)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox({double? width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor3.withOpacity(0.3),
        borderRadius: BorderRadius.circular(Dimenssions.radius4),
      ),
    );
  }
}
