// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:get/get.dart';

class ImageViewerPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String heroTagPrefix;
  const ImageViewerPage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    required this.heroTagPrefix,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) => Get.back());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleClose();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _handleClose,
          ),
          title: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              'Image ${_currentIndex + 1}/${widget.imageUrls.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        body: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const ClampingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.imageUrls.length,
              loadingBuilder: _buildLoading,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              pageController: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              scrollDirection: Axis.horizontal,
              enableRotation: false,
            ),
            if (widget.imageUrls.length > 1) _buildPageIndicator(),
          ],
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final String imageUrl = widget.imageUrls[index];
    return PhotoViewGalleryPageOptions(
      imageProvider: imageUrl.startsWith('assets/')
          ? AssetImage(imageUrl) as ImageProvider
          : NetworkImage(imageUrl),
      initialScale: PhotoViewComputedScale.contained,
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 2,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[900],
        child: const Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.white54,
            size: 40,
          ),
        ),
      ),
      filterQuality: FilterQuality.high,
    );
  }

  Widget _buildLoading(BuildContext context, ImageChunkEvent? event) {
    return Center(
      child: SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(
          value: event == null
              ? 0
              : event.expectedTotalBytes != null
                  ? event.cumulativeBytesLoaded / event.expectedTotalBytes!
                  : null,
          color: Colors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.imageUrls.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
