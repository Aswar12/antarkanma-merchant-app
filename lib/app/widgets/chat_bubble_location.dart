import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:get/get.dart';
import 'package:antarkanma_merchant/app/widgets/location_picker_dialog.dart';
import 'dart:async';

/// Enum for location bubble state
enum LocationBubbleState {
  loading,
  success,
  error,
}

/// A chat bubble widget for displaying location with loading shimmer and interactive map
/// Supports progressive rendering: shows map immediately with last known position,
/// then smoothly animates to high accuracy position when available
class ChatBubbleLocation extends StatefulWidget {
  /// Current state of the location bubble
  final LocationBubbleState state;

  /// Latitude coordinate (required for success state)
  final double? latitude;

  /// Longitude coordinate (required for success state)
  final double? longitude;

  /// GPS accuracy in meters (optional)
  final double? accuracy;

  /// Location name/label (optional)
  final String? locationName;

  /// Human-readable address (optional)
  final String? address;

  /// Whether the message is sent by current user
  final bool isMe;

  /// Callback when location is successfully fetched (for loading state)
  final Future<void> Function()? onLocationFetch;

  /// Callback when user taps on "Open in Google Maps"
  final VoidCallback? onOpenMaps;

  /// Callback when user edits/adjusts location via the picker
  /// Returns the new latitude, longitude, and address
  final void Function(double latitude, double longitude, String? address)? onLocationEdited;

  /// Width of the bubble
  final double width;

  const ChatBubbleLocation({
    super.key,
    required this.state,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.locationName,
    this.address,
    required this.isMe,
    this.onLocationFetch,
    this.onOpenMaps,
    this.onLocationEdited,
    this.width = 280,
  });

  @override
  State<ChatBubbleLocation> createState() => _ChatBubbleLocationState();
}

class _ChatBubbleLocationState extends State<ChatBubbleLocation> {
  bool _isFetchingLocation = false;
  String? _errorMessage;

  // Map controller for smooth animations
  late MapController _mapController;

  // For tracking position updates
  LatLng? _currentPosition;
  double? _currentAccuracy;

  // Animation for accuracy indicator
  Timer? _pulseTimer;
  bool _isPulsing = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializePosition();
  }

  @override
  void didUpdateWidget(ChatBubbleLocation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate map when position updates (progressive enhancement)
    if (widget.latitude != oldWidget.latitude ||
        widget.longitude != oldWidget.longitude) {
      _animateToNewPosition();
    }

    _initializePosition();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseTimer?.cancel();
    super.dispose();
  }

  void _initializePosition() {
    if (widget.latitude != null && widget.longitude != null) {
      setState(() {
        _currentPosition = LatLng(widget.latitude!, widget.longitude!);
        _currentAccuracy = widget.accuracy;
      });

      // Move map to new position smoothly
      if (widget.state == LocationBubbleState.success) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _mapController.move(_currentPosition!, 15.0);
          } catch (e) {
            // Map might not be ready yet
          }
        });
      }
    }
  }

  void _animateToNewPosition() {
    if (widget.latitude != null && widget.longitude != null) {
      final newPosition = LatLng(widget.latitude!, widget.longitude!);

      setState(() {
        _currentPosition = newPosition;
        _currentAccuracy = widget.accuracy;
      });

      // Smooth move animation to new position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(_currentPosition!, 15.0);
        } catch (e) {
          // Map might not be ready yet
        }
      });
    }
  }

  /// Build animated marker with pulse effect for loading state
  Widget _buildAnimatedMarker() {
    final isHighAccuracy = _currentAccuracy != null && _currentAccuracy! < 20;
    final markerColor = isHighAccuracy ? Colors.green : Colors.red;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse animation ring (only when updating)
        if (_isPulsing && !isHighAccuracy)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 1.5),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: markerColor.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                ),
              );
            },
            onEnd: () {
              setState(() {
                _isPulsing = false;
              });
            },
          ),
        // Main marker
        Icon(
          Icons.location_on,
          color: markerColor,
          size: 40,
        ),
        // Accuracy badge
        if (isHighAccuracy)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: context.isDark ? AppColors.darkSurface : Colors.white, width: 2),
              ),
              child: Icon(
                Icons.check,
                size: 12,
                color: context.isDark ? AppColors.darkSurface : Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.state) {
      case LocationBubbleState.loading:
        return _buildLoadingState();
      case LocationBubbleState.success:
        return _buildSuccessState();
      case LocationBubbleState.error:
        return _buildErrorState();
    }
  }

  /// Build loading state with Shimmer effect
  Widget _buildLoadingState() {
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.isMe
            ? (context.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.15))
            : context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isMe
              ? Colors.white.withValues(alpha: 0.2)
              : context.dividerColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Map Placeholder with Shimmer
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Shimmer.fromColors(
              baseColor: widget.isMe
                  ? Colors.white.withValues(alpha: 0.1)
                  : (context.isDark ? AppColors.darkDivider : Colors.grey.shade100),
              highlightColor: widget.isMe
                  ? Colors.white.withValues(alpha: 0.2)
                  : (context.isDark ? AppColors.darkCard : Colors.grey.shade50),
              child: Container(
                height: 120,
                width: double.infinity,
                color: context.surfaceColor,
                child: Stack(
                  children: [
                    // Simulated map lines
                    Positioned(
                      top: 30,
                      left: 20,
                      child: Container(
                        width: 60,
                        height: 2,
                        color: context.isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    Positioned(
                      top: 60,
                      right: 40,
                      child: Container(
                        width: 80,
                        height: 2,
                        color: context.isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 50,
                      child: Container(
                        width: 100,
                        height: 2,
                        color: context.isDark ? Colors.white10 : Colors.black12,
                      ),
                    ),
                    // Center location pin placeholder
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.isDark ? Colors.white10 : Colors.black12,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Loading spinner
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: context.isDark ? Colors.white12 : Colors.black12,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 120,
                            height: 14,
                            color: context.isDark ? Colors.white12 : Colors.black12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading Info
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: widget.isMe
                      ? Colors.white.withValues(alpha: 0.5)
                      : (context.isDark ? AppColors.darkDivider : Colors.grey.shade200),
                  highlightColor: widget.isMe
                      ? Colors.white.withValues(alpha: 0.7)
                      : (context.isDark ? AppColors.darkCard : Colors.grey.shade100),
                  child: Container(
                    width: 120,
                    height: 14,
                    color: context.surfaceColor,
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: widget.isMe
                      ? Colors.white.withValues(alpha: 0.3)
                      : (context.isDark ? AppColors.darkDivider : Colors.grey.shade200),
                  highlightColor: widget.isMe
                      ? Colors.white.withValues(alpha: 0.5)
                      : (context.isDark ? AppColors.darkCard : Colors.grey.shade100),
                  child: Container(
                    width: 80,
                    height: 10,
                    color: context.surfaceColor,
                  ),
                ),
                if (!_isFetchingLocation) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _handleLocationFetch,
                      icon: const Icon(Icons.my_location, size: 16),
                      label: const Text('Ambil Lokasi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isMe
                            ? Colors.white
                            : AppColors.chatSentBubble,
                        foregroundColor: widget.isMe
                            ? AppColors.chatSentBubble 
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build success state with FlutterMap
  Widget _buildSuccessState() {
    if (widget.latitude == null || widget.longitude == null) {
      return _buildErrorState();
    }

    final locationName = widget.locationName ?? 'Lokasi Saya';
    final address = widget.address ?? '';
    final accuracy = widget.accuracy;

    return GestureDetector(
      onTap: () => _showFullMap(),
      child: Container(
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.isMe
              ? (context.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.15))
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isMe
                ? Colors.white.withValues(alpha: 0.2)
                : context.dividerColor,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Interactive Map
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                color: context.cardColor,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentPosition ?? LatLng(widget.latitude!, widget.longitude!),
                    zoom: 15.0,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.antarkanma.merchant',
                      maxNativeZoom: 19,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition ?? LatLng(widget.latitude!, widget.longitude!),
                          width: 40,
                          height: 40,
                          builder: (context) => _buildAnimatedMarker(),
                        ),
                      ],
                    ),
                    // Optional: Add accuracy circle if accuracy is known
                    if (_currentAccuracy != null && _currentAccuracy! > 0)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: _currentPosition ?? LatLng(widget.latitude!, widget.longitude!),
                            radius: (_currentAccuracy! / 2).clamp(5, 50),
                            color: (widget.isMe ? Colors.white : Colors.red).withValues(alpha: 0.2),
                            borderStrokeWidth: 2,
                            borderColor: (widget.isMe ? (context.isDark ? AppColors.darkTextPrimary : Colors.white) : Colors.red).withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            // Location Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: widget.isMe ? Colors.white : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          locationName,
                          style: TextStyle(
                            color: widget.isMe ? Colors.white : AppColors.chatTextDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      address,
                      style: TextStyle(
                        color: widget.isMe
                            ? Colors.white.withValues(alpha: 0.85)
                            : AppColors.chatTextSecondaryLight,
                        fontSize: 10,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (accuracy != null) ...[
                    const SizedBox(height: 5),
                    // Accuracy badge with color coding
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getAccuracyColor().withValues(alpha: widget.isMe ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _getAccuracyColor().withValues(alpha: widget.isMe ? 0.5 : 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.my_location,
                            size: 10,
                            color: _getAccuracyColor(),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '±${accuracy.toStringAsFixed(1)}m',
                            style: TextStyle(
                              color: _getAccuracyColor(),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // GPS tip if accuracy is low
                    if (accuracy > 50) ...[
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: widget.isMe ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: widget.isMe ? 0.5 : 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                'Akurasi rendah. Untuk hasil lebih baik, gunakan di area terbuka.',
                                style: TextStyle(
                                  color: widget.isMe
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : Colors.amber[800],
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 6),
                  // Action buttons row
                  Row(
                    children: [
                      // Edit location button
                      Expanded(
                        child: InkWell(
                          onTap: () => _showManualAdjustment(),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isMe
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : (context.isDark ? AppColors.darkDivider : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: widget.isMe
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : context.dividerColor,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_location,
                                  size: 14,
                                  color: widget.isMe
                                      ? Colors.white
                                      : AppColors.chatAccent,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: widget.isMe
                                          ? Colors.white
                                          : AppColors.chatAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Google Maps Button
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: widget.onOpenMaps ?? () => _openInGoogleMaps(),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isMe
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : (context.isDark ? AppColors.darkCard : Colors.white),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: widget.isMe
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : context.dividerColor,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map,
                                  size: 14,
                                  color: widget.isMe
                                      ? Colors.white
                                      : (context.isDark ? Colors.green[300] : Colors.green[700]),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    'Google Maps',
                                    style: TextStyle(
                                      color: widget.isMe
                                          ? Colors.white
                                          : (context.isDark ? Colors.green[300] : Colors.green[700]),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Container(
      width: widget.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isMe
            ? (context.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.15))
            : context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isMe
              ? Colors.white.withValues(alpha: 0.2)
              : context.dividerColor,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: widget.isMe ? Colors.white : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage ?? 'Gagal memuat lokasi',
              style: TextStyle(
                color: widget.isMe ? Colors.white : AppColors.chatTextDark,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLocationFetch() async {
    if (_isFetchingLocation || widget.onLocationFetch == null) return;

    setState(() {
      _isFetchingLocation = true;
    });

    try {
      await widget.onLocationFetch!();
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mengambil lokasi: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }

  void _showFullMap() {
    if (widget.latitude == null || widget.longitude == null) return;

    Get.to(
      () => Scaffold(
        appBar: AppBar(
          title: Text(widget.locationName ?? 'Lokasi'),
          actions: [
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () => _openInGoogleMaps(),
            ),
          ],
        ),
        body: FlutterMap(
          options: MapOptions(
            center: LatLng(widget.latitude!, widget.longitude!),
            zoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.antarkanma.merchant',
              maxNativeZoom: 19,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(widget.latitude!, widget.longitude!),
                  width: 40,
                  height: 40,
                  builder: (context) => _buildAnimatedMarker(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openInGoogleMaps() {
    if (widget.latitude == null || widget.longitude == null) return;

    final url = 'https://www.google.com/maps?q=${widget.latitude!},${widget.longitude!}';
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _showManualAdjustment() async {
    if (widget.onLocationEdited == null) return;

    final result = await Get.dialog<Map<String, dynamic>>(
      LocationPickerDialog(
        initialLatitude: widget.latitude ?? -6.200000,
        initialLongitude: widget.longitude ?? 106.816666,
        initialAddress: widget.address,
      ),
      barrierDismissible: false,
    );

    if (result != null && widget.onLocationEdited != null) {
      widget.onLocationEdited!(
        result['latitude'] as double,
        result['longitude'] as double,
        result['address'] as String?,
      );
    }
  }

  Color _getAccuracyColor() {
    if (_currentAccuracy == null) return AppColors.chatAccent;

    if (_currentAccuracy! < 20) {
      return Colors.green;
    } else if (_currentAccuracy! < 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
