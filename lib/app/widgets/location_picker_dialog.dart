import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:antarkanma_merchant/theme.dart';

/// Dialog for manual location selection with draggable pin
/// User can pan the map and drop pin at exact location
/// Supports Dark Mode via BuildContext extensions
class LocationPickerDialog extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final String? initialAddress;

  const LocationPickerDialog({
    super.key,
    required this.initialLatitude,
    required this.initialLongitude,
    this.initialAddress,
  });

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  late MapController _mapController;
  late LatLng _currentPosition;
  String? _address;
  bool _isAddressLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(widget.initialLatitude, widget.initialLongitude);
    _mapController = MapController();
    _address = widget.initialAddress;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor = context.backgroundColor;
    final cardColor = context.cardColor;
    final borderColor = context.dividerColor;
    final textPrimary = context.textColor;
    final textSecondary = context.textSecondaryColor;

    return Dialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - Using brand navy for consistency
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Lokasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Geser peta atau tap untuk akurasi lebih baik',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // Map with draggable pin
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _currentPosition,
                      zoom: 17.0,
                      minZoom: 5.0,
                      maxZoom: 19.0,
                      onTap: (_, latLng) {
                        setState(() {
                          _currentPosition = latLng;
                        });
                        _getAddressFromCoordinates(latLng);
                      },
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
                            point: _currentPosition,
                            width: 50,
                            height: 50,
                            builder: (context) => const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Instruction overlay
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.pan_tool, color: Colors.white, size: 13),
                          SizedBox(width: 6),
                          Text(
                            'Geser peta atau tap untuk pindah pin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Address and action buttons
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  top: BorderSide(color: borderColor),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Coordinates display
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.my_location,
                              size: 14,
                              color: AppColors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Koordinat:',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${_currentPosition.latitude.toStringAsFixed(6)}, ${_currentPosition.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        if (_address != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_city,
                                size: 12,
                                color: AppColors.orange,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  _address!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Action buttons — compact
                  Row(
                    children: [
                      // Use current GPS location button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _currentPosition = LatLng(
                                widget.initialLatitude,
                                widget.initialLongitude,
                              );
                            });
                            _mapController.move(_currentPosition, 17.0);
                            _address = widget.initialAddress;
                          },
                          icon: const Icon(Icons.my_location, size: 15),
                          label: const Text('GPS', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.orange,
                            side: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.orange),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Confirm button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmLocation(context),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text(
                            'Gunakan Lokasi Ini',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
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

  /// Get address from coordinates (reverse geocoding)
  Future<void> _getAddressFromCoordinates(LatLng position) async {
    if (_isAddressLoading) return;

    setState(() {
      _isAddressLoading = true;
    });

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 3));

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final parts = [
          placemark.street,
          placemark.subLocality,
          placemark.locality,
        ].where((e) => e != null && e.isNotEmpty).toList();

        setState(() {
          _address = parts.isNotEmpty ? parts.join(', ') : 'Alamat tidak tersedia';
        });
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
      setState(() {
        _address = 'Alamat tidak tersedia';
      });
    } finally {
      setState(() {
        _isAddressLoading = false;
      });
    }
  }

  /// Confirm selected location and return to caller
  void _confirmLocation(BuildContext context) {
    Navigator.pop(context, {
      'latitude': _currentPosition.latitude,
      'longitude': _currentPosition.longitude,
      'address': _address,
    });
  }
}
