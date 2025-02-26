import 'package:flutter/material.dart';
import 'package:antarkanma_merchant/app/services/dimensions_service.dart';

double defaultMargin = 30.0;

// Brand Colors with Gradients
Color logoColor = const Color(0xff020238); // Deep navy blue
Color logoColorSecondary = const Color(0xffF66000); // Fixed orange color

// Gradient Lists for flexible usage
List<Color> primaryGradient = const [
  Color(0xff020238), // Deep navy blue
  Color(0xff03034d), // Slightly lighter navy blue
];

List<Color> secondaryGradient = const [
  Color(0xffF66000), // Orange
  Color(0xffFF8533), // Lighter orange
];

List<Color> brandGradient = const [
  Color(0xff020238), // Deep navy blue
  Color(0xffF66000), // Orange
];

Color primaryColor = const Color(0xff6C5ECF);
Color secondaryColor = const Color(0xff38ABBE);
Color alertColor = const Color(0xffED6363);
Color priceColor = const Color(0xff2C96F1);
Color backgroundColor1 = const Color(0xFFFFFFFF);
Color backgroundColor2 = const Color(0xFFFEFEFF);
Color backgroundColor3 = const Color(0xFFDDDDDD);
Color backgroundColor4 = const Color(0xff252836);
Color backgroundColor5 = const Color(0xFFD4D1D1);
Color backgroundColor6 = const Color(0xFF000000);
Color backgroundColor7 = const Color(0xFF000000);
Color backgroundColor8 = const Color(0XFFf3f5f4);
Color primaryTextColor = const Color(0xFF0C0C0C);
Color secondaryTextColor = const Color(0xFF585858);
Color subtitleColor = const Color(0xFF8E8E97);
Color transparentColor = Colors.transparent;
Color blackColor = const Color(0xff2E2E2E);

const MaterialColor primarySwatch = MaterialColor(
  0xFFFF6600,
  <int, Color>{
    50: Color(0xFFFFECE0),
    100: Color(0xFFFFD4B3),
    200: Color(0xFFFFB980),
    300: Color(0xFFFF9D4D),
    400: Color(0xFFFF8726),
    500: Color(0xFFFF6600),
    600: Color(0xFFFF5E00),
    700: Color(0xFFFF5300),
    800: Color(0xFFFF4900),
    900: Color(0xFFFF3600),
  },
);

TextStyle primaryTextStyle = TextStyle(
  color: primaryTextColor,
  fontFamily: 'PalanquinDark',
  fontWeight: regular,
);

TextStyle secondaryTextStyle = TextStyle(
  color: secondaryTextColor,
  fontFamily: 'PalanquinDark',
  fontWeight: regular,
);

TextStyle subtitleTextStyle = TextStyle(
  color: subtitleColor,
  fontFamily: 'PalanquinDark',
  fontWeight: regular,
);

TextStyle priceTextStyle = TextStyle(
  color: logoColor,
  fontFamily: 'PalanquinDark',
  fontWeight: medium,
);

TextStyle purpleTextStyle = TextStyle(
  color: primaryColor,
  fontFamily: 'PalanquinDark',
  fontWeight: regular,
);

TextStyle blackTextStyle = TextStyle(
  color: blackColor,
  fontFamily: 'PalanquinDark',
  fontWeight: regular,
);

TextStyle alertTextStyle = TextStyle(
  color: alertColor,
  fontFamily: 'PalanquinDark',
  fontWeight: regular,
);

TextStyle textwhite = TextStyle(
  color: backgroundColor1,
  fontFamily: 'PalanquinDark',
  fontWeight: regular,
);

TextStyle primaryTextOrange = TextStyle(
  color: logoColorSecondary,
  fontFamily: 'PalanquinDark',
  fontWeight: regular,
);

FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semiBold = FontWeight.w600;
FontWeight bold = FontWeight.w700;

class Dimenssions {
  static double get screenHeight => DimensionsService.to.screenHeight;
  static double get screenWidth => DimensionsService.to.screenWidth;

  // Updated pageView dimensions for better carousel display
  static double get pageView => screenHeight / 2.2; // Increased from 2.64
  static double get pageViewContainer => screenHeight / 3.84;
  static double get pageTextContainer => screenHeight / 7.03;

  // Dynamic height padding and margin
  static double get height2 => screenHeight / 422;
  static double get height4 => screenHeight / 211;
  static double get height5 => screenHeight / 168.8;
  static double get height6 => screenHeight / 140.67;
  static double get height8 => screenHeight / 105.5;
  static double get height10 => screenHeight / 84.4;
  static double get height12 => screenHeight / 70.33;
  static double get height15 => screenHeight / 56.27;
  static double get height16 => screenHeight / 52.75;
  static double get height18 => screenHeight / 46.89;
  static double get height24 => screenHeight / 35.17;
  static double get height28 => screenHeight / 30.14;
  static double get height32 => screenHeight / 26.38;
  static double get height48 => screenHeight / 17.58;
  static double get height20 => screenHeight / 42.2;
  static double get height22 => screenHeight / 38.45;
  static double get height25 => screenHeight / 33.76;
  static double get height30 => screenHeight / 28.13;
  static double get height35 => screenHeight / 24.38;
  static double get height40 => screenHeight / 21.1;
  static double get height45 => screenHeight / 18.76;
  static double get height50 => screenHeight / 16.42;
  static double get height55 => screenHeight / 14.78;
  static double get height60 => screenHeight / 13.14;
  static double get height65 => screenHeight / 11.5;
  static double get height70 => screenHeight / 10.21;
  static double get height75 => screenHeight / 9.09;
  static double get height80 => screenHeight / 8.13;
  static double get height85 => screenHeight / 7.3;
  static double get height90 => screenHeight / 6.58;
  static double get height95 => screenHeight / 6;
  static double get height100 => screenHeight / 5.53;
  static double get height105 => screenHeight / 5.14;
  static double get height150 => screenHeight / 5.6;
  static double get height180 => screenHeight / 4.44;
  static double get height200 => screenHeight / 3.84;
  static double get height210 => screenHeight / 3.57;
  static double get height220 => screenHeight / 3.33;
  static double get height230 => screenHeight / 3.13;
  static double get height240 => screenHeight / 2.95;
  static double get height250 => screenHeight / 2.8;
  static double get height255 => screenHeight / 2.7;

  // Dynamic width padding and margin
  static double get width2 => screenHeight / 422;
  static double get width4 => screenHeight / 211;
  static double get width5 => screenHeight / 168.8;
  static double get width6 => screenHeight / 140.67;
  static double get width8 => screenHeight / 105.5;
  static double get width10 => screenHeight / 84.4;
  static double get width12 => screenHeight / 70.33;
  static double get width15 => screenHeight / 56.27;
  static double get width16 => screenHeight / 52.75;
  static double get width18 => screenHeight / 46.89;
  static double get width20 => screenHeight / 42.2;
  static double get width25 => screenHeight / 33.64;
  static double get width30 => screenHeight / 28.13;
  static double get width35 => screenHeight / 23.88;
  static double get width40 => screenHeight / 21.1;
  static double get width45 => screenHeight / 18.76;
  static double get width50 => screenHeight / 16.88;
  static double get width55 => screenHeight / 15.27;
  static double get width60 => screenHeight / 13.14;
  static double get width65 => screenHeight / 11.5;
  static double get width70 => screenHeight / 10.21;
  static double get width80 => screenHeight / 10.52;
  static double get width85 => screenHeight / 7.3;
  static double get width90 => screenHeight / 6.58;
  static double get width95 => screenHeight / 6;
  static double get width100 => screenHeight / 5.53;
  static double get width105 => screenHeight / 5.14;
  static double get width110 => screenHeight / 4.76;
  static double get width120 => screenHeight / 4.44;
  static double get width125 => screenHeight / 4.24;
  static double get width130 => screenHeight / 3.97;
  static double get width135 => screenHeight / 3.77;
  static double get width140 => screenHeight / 3.59;
  static double get width150 => screenHeight / 5.64;

  // Font sizes
  static double get font10 => screenHeight / 85.33;
  static double get font12 => screenHeight / 70.28;
  static double get font14 => screenHeight / 62;
  static double get font16 => screenHeight / 53.75;
  static double get font18 => screenHeight / 47.78;
  static double get font20 => screenHeight / 42.2;
  static double get font22 => screenHeight / 37.78;
  static double get font24 => screenHeight / 34.29;
  static double get font26 => screenHeight / 32.46;
  static double get font28 => screenHeight / 30.14;

  // Radius
  static double get radius4 => screenHeight / 211;
  static double get radius6 => screenHeight / 140.67;
  static double get radius8 => screenHeight / 105.5;
  static double get radius12 => screenHeight / 70.33;
  static double get radius15 => screenHeight / 52.75;
  static double get radius16 => screenHeight / 52.75;
  static double get radius20 => screenHeight / 42.2;
  static double get radius30 => screenHeight / 28.13;

  // Icon sizes
  static double get iconSize20 => screenHeight / 42.2;
  static double get iconSize24 => screenHeight / 35.16;
  static double get iconSize16 => screenHeight / 52.75;

  // List view sizes
  static double get listViewImgSize => screenWidth / 3.25;
  static double get listViewTextContSize => screenWidth / 3.9;

  // Popular food detail
  static double get popularFoodDetailImgSize => screenHeight / 2.5;

  // Bottom height bar
  static double get boottomHeightBar => screenHeight / 7.03;
}
