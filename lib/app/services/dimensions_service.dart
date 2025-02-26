import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DimensionsService extends GetxService {
  static DimensionsService get to => Get.find();
  
  // Using Rx values to make them reactive
  final _screenHeight = 0.0.obs;
  final _screenWidth = 0.0.obs;

  double get screenHeight => _screenHeight.value == 0 ? _getDefaultHeight() : _screenHeight.value;
  double get screenWidth => _screenWidth.value == 0 ? _getDefaultWidth() : _screenWidth.value;

  double _getDefaultHeight() {
    return ui.PlatformDispatcher.instance.views.first.physicalSize.height / 
           ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
  }

  double _getDefaultWidth() {
    return ui.PlatformDispatcher.instance.views.first.physicalSize.width / 
           ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
  }

  @override
  void onInit() {
    super.onInit();
    _updateDimensions();
    
    // Listen for orientation changes
    ui.PlatformDispatcher.instance.onMetricsChanged = _updateDimensions;
    
    // Update dimensions after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateDimensions();
    });
  }

  void _updateDimensions() {
    final view = ui.PlatformDispatcher.instance.views.first;
    _screenHeight.value = view.physicalSize.height / view.devicePixelRatio;
    _screenWidth.value = view.physicalSize.width / view.devicePixelRatio;
  }

  @override
  void onClose() {
    ui.PlatformDispatcher.instance.onMetricsChanged = null;
    super.onClose();
  }

  Future<DimensionsService> init() async {
    _updateDimensions();
    return this;
  }
}
