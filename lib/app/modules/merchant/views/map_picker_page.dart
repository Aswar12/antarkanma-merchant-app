import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:antarkanma_merchant/theme.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  bool _isLoading = true;
  bool _isGettingAccurateLocation = false;
  String _accuracy = '';
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;

  // Default location (Sulawesi Selatan)
  final LatLng _defaultLocation = const LatLng(-4.64714990, 119.58491240);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  void _moveMap(LatLng location, double zoom) {
    if (!mounted) return;
    
    try {
      _mapController.move(location, zoom);
    } catch (e) {
      print('Error moving map: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _selectedLocation = _defaultLocation;
          _isLoading = false;
        });
        _moveMap(_defaultLocation, 15);
        Get.snackbar(
          'Info',
          'Layanan lokasi tidak aktif. Menggunakan lokasi default.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _selectedLocation = _defaultLocation;
            _isLoading = false;
          });
          _moveMap(_defaultLocation, 15);
          Get.snackbar(
            'Info',
            'Izin lokasi ditolak. Menggunakan lokasi default.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _selectedLocation = _defaultLocation;
          _isLoading = false;
        });
        _moveMap(_defaultLocation, 15);
        Get.snackbar(
          'Info',
          'Izin lokasi ditolak secara permanen. Menggunakan lokasi default.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // Get high-accuracy location
      await _getAccurateLocation();
    } catch (e) {
      setState(() {
        _selectedLocation = _defaultLocation;
        _isLoading = false;
      });
      _moveMap(_defaultLocation, 15);
      Get.snackbar(
        'Error',
        'Gagal mendapatkan lokasi: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _getAccurateLocation() async {
    if (!mounted) return;
    
    setState(() {
      _isGettingAccurateLocation = true;
      _accuracy = 'Mendapatkan lokasi akurat...';
    });

    try {
      // Ensure map is initialized
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Cancel any existing stream
      await _positionStream?.cancel();

      // Get initial position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 30),
        forceAndroidLocationManager: true,
      );

      // Start listening to location updates with specific settings
      final LocationSettings locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        forceLocationManager: true,
        intervalDuration: const Duration(milliseconds: 500),
        //(Optional) Set if your app supports Android 12 or higher
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "Mendapatkan lokasi akurat...",
          notificationTitle: "Lokasi sedang diperbarui",
          enableWakeLock: true,
        ),
      );

      _positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((Position newPosition) async {
        // Check if accuracy is better than previous position
        if (_currentPosition == null || 
            newPosition.accuracy < _currentPosition!.accuracy) {
          _currentPosition = newPosition;
          
          setState(() {
            _selectedLocation = LatLng(newPosition.latitude, newPosition.longitude);
            _accuracy = 'Akurasi: ${newPosition.accuracy.toStringAsFixed(2)} meter';
            
            // If accuracy is good enough, stop listening
            if (newPosition.accuracy < 10) {
              _positionStream?.cancel();
              _isGettingAccurateLocation = false;
              Get.snackbar(
                'Sukses',
                'Lokasi akurat ditemukan!',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            }
          });

          _moveMap(_selectedLocation!, 18);
        }
      });

      // Set initial position while waiting for better accuracy
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _currentPosition = position;
        _accuracy = 'Akurasi: ${position.accuracy.toStringAsFixed(2)} meter';
        _isLoading = false;
      });

      _moveMap(_selectedLocation!, 18);

      // Set a timeout to stop getting updates after 30 seconds
      await Future.delayed(const Duration(seconds: 30));
      await _positionStream?.cancel();
      setState(() {
        _isGettingAccurateLocation = false;
        if (_currentPosition!.accuracy > 20) {
          Get.snackbar(
            'Peringatan',
            'Tidak dapat mendapatkan lokasi yang sangat akurat. Akurasi saat ini: ${_currentPosition!.accuracy.toStringAsFixed(2)} meter',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
          );
        }
      });

    } catch (e) {
      setState(() {
        _selectedLocation = _defaultLocation;
        _isLoading = false;
        _isGettingAccurateLocation = false;
      });
      _moveMap(_defaultLocation, 15);
      Get.snackbar(
        'Error',
        'Gagal mendapatkan lokasi akurat: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pilih Lokasi',
          style: primaryTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semiBold,
          ),
        ),
        backgroundColor: backgroundColor1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _selectedLocation ?? _defaultLocation,
                    zoom: 18,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.antarkanma.merchant',
                    ),
                    MarkerLayer(
                      markers: [
                        if (_selectedLocation != null)
                          Marker(
                            point: _selectedLocation!,
                            width: 40,
                            height: 40,
                            builder: (context) => const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                // Accuracy indicator
                if (_isGettingAccurateLocation || _accuracy.isNotEmpty)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (_isGettingAccurateLocation)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _accuracy,
                              style: primaryTextStyle.copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Select location button
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_isGettingAccurateLocation)
                        ElevatedButton.icon(
                          onPressed: _getAccurateLocation,
                          icon: const Icon(Icons.gps_fixed),
                          label: const Text('Dapatkan Lokasi Akurat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: logoColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_selectedLocation != null) {
                            if (_currentPosition != null && 
                                _currentPosition!.accuracy > 20) {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Peringatan'),
                                  content: const Text(
                                    'Lokasi yang dipilih mungkin tidak akurat. '
                                    'Apakah Anda yakin ingin menggunakan lokasi ini?'
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        Get.back(result: _selectedLocation);
                                      },
                                      child: const Text('Ya'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              Get.back(result: _selectedLocation);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: logoColorSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Pilih Lokasi Ini',
                          style: textwhite.copyWith(
                            fontSize: 16,
                            fontWeight: semiBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
