import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme.dart';
import '../controllers/splash_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final splashController = Get.find<SplashController>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                    // Shimmer Loading Animation
                    SizedBox(
                      width: Dimenssions.width150 * 1.33,
                      height: 4,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: logoColorSecondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              return Positioned(
                                left: -100 + (_controller.value * 300),
                                child: Container(
                                  width: 100,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        logoColorSecondary.withOpacity(0.0),
                                        logoColorSecondary,
                                        logoColorSecondary.withOpacity(0.0),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimenssions.height20),
                    // Loading Text
                    Obx(() => splashController.isLoading
                        ? Column(
                            children: [
                              SizedBox(height: Dimenssions.height20),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Dimenssions.width20,
                                  vertical: Dimenssions.height10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(
                                      Dimenssions.radius20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          logoColorSecondary.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Obx(() => Text(
                                      splashController.loadingText,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Dimenssions.font16,
                                        fontWeight: FontWeight.w500,
                                        shadows: [
                                          Shadow(
                                            color: logoColorSecondary,
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                            ],
                          )
                        : const SizedBox.shrink()),
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
