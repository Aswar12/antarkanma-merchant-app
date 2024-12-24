import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma/theme.dart';

class MerchantHomePage extends StatelessWidget {
  const MerchantHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Merchant Home'),
      ),
      body: Center(
        child: Text(
          'Welcome to the Merchant Home Page',
          style: primaryTextStyle,
        ),
      ),
    );
  }
}
