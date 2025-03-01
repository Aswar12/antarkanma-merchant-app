import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/theme.dart';

class CachedImageView extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? placeholder;
  final BorderRadius? borderRadius;

  const CachedImageView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder = 'assets/image_shoes.png',
    this.borderRadius,
  });

  bool _isValidUrl(String url) {
    return url.isNotEmpty && 
           (url.startsWith('http://') || url.startsWith('https://')) &&
           Uri.tryParse(url)?.hasAbsolutePath == true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidUrl(imageUrl)) {
      return _buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        maxWidthDiskCache: 1000,
        maxHeightDiskCache: 1000,
        memCacheWidth: 800,
        memCacheHeight: 800,
        placeholder: (context, url) => _buildLoadingState(),
        errorWidget: (context, url, error) {
          debugPrint('Error loading image: $url');
          debugPrint('Error details: $error');
          return _buildPlaceholder();
        },
        fadeInDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor3.withOpacity(0.1),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(logoColorSecondary),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor3.withOpacity(0.1),
        borderRadius: borderRadius,
        image: placeholder != null && placeholder!.isNotEmpty
            ? DecorationImage(
                image: AssetImage(placeholder!),
                fit: fit,
              )
            : null,
      ),
      child: placeholder == null || placeholder!.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: secondaryTextColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No Image',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
