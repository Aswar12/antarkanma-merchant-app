// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../theme.dart';
import '../controllers/splash_controller.dart';
import 'package:percent_indicator/percent_indicator.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: logoColor,
        body: SafeArea(
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 500),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/merchant_nobg.png',
                    width: Dimenssions.width150,
                    height: Dimenssions.height150,
                  ),
                  SizedBox(height: Dimenssions.height32),

                  // Custom Animated Progress Bar
                  SizedBox(
                    width: Dimenssions.width150 * 1.33,
                    child: Column(
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 2),
                          builder: (context, value, _) =>
                              LinearPercentIndicator(
                            width: Dimenssions.width150 * 1.33,
                            lineHeight: 8.0,
                            percent: value,
                            animation: false,
                            backgroundColor: Colors.white,
                            progressColor: logoColorSecondary,
                            barRadius: const Radius.circular(10),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
