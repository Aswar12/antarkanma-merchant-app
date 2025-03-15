import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme.dart';
import '../controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: logoColor,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background Design Elements
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: Dimenssions.width150,
                  height: Dimenssions.height150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -80,
                child: Container(
                  width: Dimenssions.width150 * 1.33,
                  height: Dimenssions.height200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Main Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Static Logo
                    SizedBox(
                      width: Dimenssions.width150,
                      height: Dimenssions.height150,
                      child: Image.asset(
                        'assets/Logo_AntarkanmaNoBg.png',
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.error_outline,
                            color: alertColor,
                            size: Dimenssions.iconSize24,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: Dimenssions.height32),
                    // Loading Indicator
                    SizedBox(
                      width: Dimenssions.width150 * 1.33,
                      child: LinearProgressIndicator(
                        backgroundColor: logoColorSecondary.withOpacity(0.2),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(logoColorSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
