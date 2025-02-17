// ignore_for_file: deprecated_member_use

import 'package:antarkanma_merchant/app/controllers/map_picker_controller.dart';
import 'package:antarkanma_merchant/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

class MapPickerView extends StatefulWidget {
  const MapPickerView({super.key});

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  late final MapPickerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MapPickerController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeMap();
    });
  }

  @override
  void dispose() {
    Get.delete<MapPickerController>();
    super.dispose();
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Pilih Lokasi',
        style: primaryTextStyle.copyWith(
          fontSize: Dimenssions.font18,
          fontWeight: semiBold,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: logoColorSecondary,
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.my_location,
            color: logoColorSecondary,
          ),
          onPressed: () {
            controller.getCurrentLocation();
            // Center the map on the user's current location
            controller.updateLocation(controller.currentLocation);
          },
          tooltip: 'Lokasi Saat Ini',
        ),
      ],
      backgroundColor: backgroundColor1,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            _buildMap(),
            Positioned(
              bottom: 90,
              left: 16,
              right: 16,
              child: _buildLocationInfo(),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildConfirmButton(),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return Obx(() => FlutterMap(
          mapController: controller.mapController.value,
          options: MapOptions(
            center: controller.selectedLocation.value,
            zoom: 15.0,
            onTap: (_, latLng) => controller.updateLocation(latLng),
            minZoom: 5.0,
            maxZoom: 18.0,
            interactiveFlags: InteractiveFlag.all,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: controller.selectedLocation.value,
                  width: 50,
                  height: 50,
                  builder: (context) => _buildMarker(),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildMarker() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 24,
          ),
        ),
        Container(
          width: 2,
          height: 8,
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimenssions.radius15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('Koordinat:', controller.formattedLocation),
              const SizedBox(height: 12),
              _buildInfoRow('Alamat:', controller.currentAddress.value),
            ],
          )),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return FloatingActionButton.extended(
      onPressed: () => controller.confirmLocation(),
      icon: const Icon(Icons.check),
      label: const Text('Konfirmasi'),
      backgroundColor: logoColorSecondary,
    );
  }
}
