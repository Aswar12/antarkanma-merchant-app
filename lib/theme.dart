import 'package:flutter/material.dart';
import 'package:get/get.dart';

double defaultMargin = Dimenssions.height10;

// ============================================
// 🎨 NEW COLOR SYSTEM - Clean & Simple
// ============================================
// Primary Brand Colors
// - Navy Logo: Main brand color (headers, buttons, accents)
// - Orange Logo: Accent color (CTA, highlights, badges)
// ============================================

// Brand Colors
Color navyColor = const Color(0xFF000033);      // Antarkanma Navy - Matches Logo Background
Color orangeColor = const Color(0xFFFF6600);    // Orange Logo - Accent

// Background Colors (Black & White Only)
Color backgroundLight = const Color(0xFFFFFFFF);     // Pure White (Light Mode)
Color backgroundLightAlt = const Color(0xFFF8F9FA);  // Off-White (subtle variation)
Color backgroundDark = const Color(0xFF000000);      // Pure Black (Dark Mode)
Color backgroundDarkAlt = const Color(0xFF1A1A1A);   // Off-Black (subtle variation)

// Legacy - Will be removed in future
Color get priceColor => Get.isDarkMode ? Colors.white : const Color(0xff2C96F1);

// Transparent color helper
Color transparentColor = Colors.transparent;

// Dark Mode Color Palette
class AppColors {
  // ============================================
  // 🎨 BRAND COLORS
  // ============================================
  static const Color navy = Color(0xFF000033);      // Navy Logo Background - Matches Logo
  static const Color navyDark = Color(0xFF020206);  // Darker Navy for App Bars
  static const Color orange = Color(0xFFFF6600);    // Orange Logo - Accent

  // ============================================
  // 🔄 LEGACY ALIASES - For backward compatibility
  // ============================================
  // These are used by existing merchant/courier code
  // dashPrimary = orange (brand accent color)
  // dashNavyDeep = navy (brand primary color)
  static const Color dashPrimary = orange;
  static const Color dashNavyDeep = navy;
  static const Color dashTextDark = navy;

  // ============================================
  // 🌈 LIGHT MODE COLORS
  // ============================================
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightBackgroundAlt = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextHint = Color(0xFF999999);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightInputBorder = Color(0xFFDDDDDD);

  // ============================================
  // 🌙 DARK MODE COLORS
  // ============================================
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkBackgroundAlt = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFCCCCCC);
  static const Color darkTextHint = Color(0xFF666666);
  static const Color darkDivider = Color(0xFF333333);
  static const Color darkInputBorder = Color(0xFF444444);

  // ============================================
  // ⚡ FUNCTIONAL COLORS
  // ============================================
  static const Color error = Color(0xFFED6363);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);

  // ============================================
  // 🔄 BACK COMPATIBILITY ALIASES
  // ============================================
  // These are aliases for backward compatibility
  // Use navy/orange instead in new code
  static const Color primary = navy;      // Alias for navy
  static const Color secondary = orange;  // Alias for orange
  static const Color accent = orange;     // Alias for orange

  // ============================================
  // 💬 CHAT COLORS (Keep Existing - Already Good)
  // ============================================
  static const Color chatBubbleLight = Color(0xFFFFFFFF);
  static const Color chatBubbleDark = Color(0xFF2C2C2C);
  static const Color chatSentBubble = Color(0xFF1E3A8A); // Navy Blue
  static const Color chatAccent = Color(0xFFF97316); // Bright Orange
  static const Color chatTextLight = Color(0xFF0F172A);
  static const Color chatTextDark = Color(0xFFE0E0E0);
  static const Color chatTextSecondaryLight = Color(0xFF64748B);
  static const Color chatTextSecondaryDark = Color(0xFF9E9E9E);
  static const Color chatBackgroundLight = Color(0xFFF8FAFC);
  static const Color chatBackgroundDark = Color(0xFF1A1A1A);
}

// ============================================
// ⚠️ DEPRECATED - Use AppColors Instead
// ============================================
// These are kept for backward compatibility but should NOT be used in new code.
// Please use AppColors.navy, AppColors.orange, AppColors.lightBackground, etc.

// Old Background Colors
@Deprecated('Use AppColors.lightBackground or AppColors.darkBackground')
Color get backgroundColor1 => Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

@Deprecated('Use AppColors.lightSurface or AppColors.darkSurface')
Color get backgroundColor2 => Get.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;

@Deprecated('Use AppColors.lightBackground or AppColors.darkBackground')
Color get backgroundColor3 => Get.isDarkMode ? AppColors.darkBackgroundAlt : AppColors.lightBackgroundAlt;

@Deprecated('Use AppColors.darkBackground')
Color get backgroundColor4 => AppColors.darkBackground;

@Deprecated('Use AppColors.lightBackground or AppColors.darkBackground')
Color get backgroundColor5 => Get.isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

@Deprecated('Use AppColors.darkBackground')
Color get backgroundColor6 => AppColors.darkBackground;

@Deprecated('Use AppColors.darkBackground')
Color get backgroundColor7 => AppColors.darkBackground;

@Deprecated('Use AppColors.lightBackground or AppColors.lightSurface')
Color get backgroundColor8 => Get.isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;

// Old Text Colors
@Deprecated('Use AppColors.lightTextPrimary or AppColors.darkTextPrimary')
Color get primaryTextColor => Get.isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

@Deprecated('Use AppColors.lightTextSecondary or AppColors.darkTextSecondary')
Color get secondaryTextColor => Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

@Deprecated('Use AppColors.lightTextHint or AppColors.darkTextHint')
Color get subtitleColor => Get.isDarkMode ? AppColors.darkTextHint : AppColors.lightTextHint;

// Legacy Colors (Will be removed in future)
@Deprecated('Use AppColors.navy')
Color primaryColor = AppColors.navy;

@Deprecated('Use AppColors.orange')
Color secondaryColor = AppColors.orange;

@Deprecated('Use AppColors.navy')
Color logoColor = AppColors.navy;

@Deprecated('Use AppColors.orange')
Color logoColorSecondary = AppColors.orange;

@Deprecated('Use AppColors.orange')
Color primaryOrange = AppColors.orange;

@Deprecated('Use AppColors.error')
Color alertColor = AppColors.error;

@Deprecated('Use AppColors.lightTextPrimary or AppColors.darkTextPrimary')
Color blackColor = AppColors.lightTextPrimary;

@Deprecated('Use AppColors.lightTextPrimary or AppColors.darkTextPrimary')
Color textwhiteColor = AppColors.lightTextPrimary;

// Chat Legacy Aliases
@Deprecated('Use AppColors.chatSentBubble')
Color get chatPrimary => AppColors.chatSentBubble;

@Deprecated('Use AppColors.chatAccent')
Color get chatSecondary => AppColors.chatAccent;

@Deprecated('Use AppColors.chatBackgroundLight or AppColors.chatBackgroundDark')
Color get chatBackgroundLight => Get.isDarkMode ? AppColors.chatBackgroundDark : AppColors.chatBackgroundLight;

@Deprecated('Use AppColors.chatBubbleLight or AppColors.chatBubbleDark')
Color get chatBubbleMerchant => Get.isDarkMode ? AppColors.chatBubbleDark : AppColors.chatBubbleLight;

@Deprecated('Use AppColors.chatTextLight or AppColors.chatTextDark')
Color get chatTextDark => Get.isDarkMode ? AppColors.chatTextDark : AppColors.chatTextLight;

@Deprecated('Use AppColors.chatTextSecondaryLight or AppColors.chatTextSecondaryDark')
Color get chatTextSecondary => Get.isDarkMode ? AppColors.chatTextSecondaryDark : AppColors.chatTextSecondaryLight;


// ============================================
// 📏 DIMENSIONS & HELPER EXTENSIONS
// ============================================

extension ThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Semantic Colors
  Color get backgroundColor =>
      isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get backgroundColorAlt =>
      isDark ? AppColors.darkBackgroundAlt : AppColors.lightBackgroundAlt;
  Color get surfaceColor =>
      isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get cardColor => isDark ? AppColors.darkCard : AppColors.lightCard;
  Color get textColor =>
      isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondaryColor =>
      isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textHintColor =>
      isDark ? AppColors.darkTextHint : AppColors.lightTextHint;
  Color get dividerColor =>
      isDark ? AppColors.darkDivider : AppColors.lightDivider;
  Color get inputBorderColor =>
      isDark ? AppColors.darkInputBorder : AppColors.lightInputBorder;
}

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

TextStyle get primaryTextStyle => TextStyle(
      color: Get.isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      fontFamily: 'PalanquinDark',
      fontWeight: regular,
    );

TextStyle get secondaryTextStyle => TextStyle(
      color: Get.isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      fontFamily: 'PalanquinDark',
      fontWeight: regular,
    );

TextStyle get subtitleTextStyle => TextStyle(
      color: Get.isDarkMode ? AppColors.darkTextHint : AppColors.lightTextHint,
      fontFamily: 'PalanquinDark',
      fontWeight: regular,
    );

TextStyle get priceTextStyle => TextStyle(
      color: Get.isDarkMode ? Colors.white : AppColors.navy,
      fontFamily: 'PalanquinDark',
      fontWeight: medium,
    );

TextStyle get purpleTextStyle => TextStyle(
      color: Get.isDarkMode ? Colors.white : AppColors.navy,
      fontFamily: 'PalanquinDark',
      fontWeight: regular,
    );

TextStyle get blackTextStyle => TextStyle(
      color: Get.isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      fontFamily: 'PalanquinDark',
      fontWeight: regular,
    );

TextStyle get alertTextStyle => TextStyle(
      color: AppColors.error,
      fontFamily: 'PalanquinDark',
      fontWeight: regular,
    );

TextStyle get textwhite => TextStyle(
      color: Colors.white,
      fontFamily: 'PalanquinDark',
      fontWeight: regular,
    );

TextStyle get primaryTextOrange => TextStyle(
      color: AppColors.orange,
      fontFamily: 'PalanquinDark',
      fontWeight: regular,
    );

FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semiBold = FontWeight.w600;
FontWeight bold = FontWeight.w700;

class Dimenssions {
  static double screenHeight =
      MediaQueryData.fromView(WidgetsBinding.instance.window).size.height;
  static double screenWidth =
      MediaQueryData.fromView(WidgetsBinding.instance.window).size.width;

  // Updated pageView dimensions for better carousel display
  static double pageView = screenHeight / 2.2; // Increased from 2.64
  static double pageViewContainer = screenHeight / 3.84;
  static double pageTextContainer = screenHeight / 7.03;

  // Dynamic height padding and margin
  static double height2 = screenHeight / 422;
  static double height4 = screenHeight / 211;
  static double height5 = screenHeight / 168.8;
  static double height6 = screenHeight / 140.67;
  static double height8 = screenHeight / 105.5;
  static double height10 = screenHeight / 84.4;
  static double height12 = screenHeight / 70.33;
  static double height15 = screenHeight / 56.27;
  static double height16 = screenHeight / 52.75;
  static double height18 = screenHeight / 46.89;
  static double height24 = screenHeight / 35.17;
  static double height28 = screenHeight / 30.14;
  static double height32 = screenHeight / 26.38;
  static double height48 = screenHeight / 17.58;
  static double height20 = screenHeight / 42.2;
  static double height22 = screenHeight / 38.45;
  static double height25 = screenHeight / 33.76;
  static double height30 = screenHeight / 28.13;
  static double height35 = screenHeight / 24.38;
  static double height40 = screenHeight / 21.1;
  static double height45 = screenHeight / 18.76;
  static double height50 = screenHeight / 16.42;
  static double height55 = screenHeight / 14.78;
  static double height60 = screenHeight / 13.14;
  static double height65 = screenHeight / 11.5;
  static double height70 = screenHeight / 10.21;
  static double height75 = screenHeight / 9.09;
  static double height80 = screenHeight / 8.13;
  static double height85 = screenHeight / 7.3;
  static double height90 = screenHeight / 6.58;
  static double height95 = screenHeight / 6;
  static double height100 = screenHeight / 5.53;
  static double height105 = screenHeight / 5.14;
  static double height150 = screenHeight / 5.6;
  static double height180 = screenHeight / 4.44;
  static double height200 = screenHeight / 3.84;
  static double height210 = screenHeight / 3.57;
  static double height220 = screenHeight / 3.33;
  static double height230 = screenHeight / 3.13;
  static double height240 = screenHeight / 2.95;
  static double height250 = screenHeight / 2.8;
  static double height255 = screenHeight / 2.7;

  // Dynamic width padding and margin
  static double width2 = screenHeight / 422;
  static double width4 = screenHeight / 211;
  static double width5 = screenHeight / 168.8;
  static double width6 = screenHeight / 140.67;
  static double width8 = screenHeight / 105.5;
  static double width10 = screenHeight / 84.4;
  static double width12 = screenHeight / 70.33;
  static double width15 = screenHeight / 56.27;
  static double width16 = screenHeight / 52.75;
  static double width18 = screenHeight / 46.89;
  static double width20 = screenHeight / 42.2;
  static double width25 = screenHeight / 33.64;
  static double width30 = screenHeight / 28.13;
  static double width35 = screenHeight / 23.88;
  static double width40 = screenHeight / 21.1;
  static double width45 = screenHeight / 18.76;
  static double width50 = screenHeight / 16.88;
  static double width55 = screenHeight / 15.27;
  static double width60 = screenHeight / 13.14;
  static double width65 = screenHeight / 11.5;
  static double width70 = screenHeight / 10.21;
  static double width80 = screenHeight / 10.52;
  static double width85 = screenHeight / 7.3;
  static double width90 = screenHeight / 6.58;
  static double width95 = screenHeight / 6;
  static double width100 = screenHeight / 5.53;
  static double width105 = screenHeight / 5.14;
  static double width110 = screenHeight / 4.76;
  static double width120 = screenHeight / 4.44;
  static double width125 = screenHeight / 4.24;
  static double width130 = screenHeight / 3.97;
  static double width135 = screenHeight / 3.77;
  static double width140 = screenHeight / 3.59;
  static double width150 = screenHeight / 5.64;

  // Font sizes
  static double font10 = screenHeight / 85.33;
  static double font11 = screenHeight / 77.64;
  static double font12 = screenHeight / 70.28;
  static double font13 = screenHeight / 65.0;
  static double font14 = screenHeight / 62;
  static double font15 = screenHeight / 56.27;
  static double font16 = screenHeight / 53.75;
  static double font18 = screenHeight / 47.78;
  static double font20 = screenHeight / 42.2;
  static double font22 = screenHeight / 37.78;
  static double font24 = screenHeight / 34.29;
  static double font26 = screenHeight / 32.46;
  static double font28 = screenHeight / 30.14;

  // Radius
  static double radius4 = screenHeight / 211;
  static double radius6 = screenHeight / 140.67;
  static double radius8 = screenHeight / 105.5;
  static double radius12 = screenHeight / 70.33;
  static double radius15 = screenHeight / 52.75;
  static double radius16 = screenHeight / 52.75;
  static double radius20 = screenHeight / 42.2;
  static double radius30 = screenHeight / 28.13;

  // Icon sizes
  static double iconSize20 = screenHeight / 42.2;
  static double iconSize24 = screenHeight / 35.16;
  static double iconSize16 = screenHeight / 52.75;

  // List view sizes
  static double listViewImgSize = screenWidth / 3.25;
  static double listViewTextContSize = screenWidth / 3.9;

  // Popular food detail
  static double popularFoodDetailImgSize = screenHeight / 2.5;

  // Bottom height bar
  static double boottomHeightBar = screenHeight / 7.03;
}
