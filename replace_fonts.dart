import 'dart:io';

void main() {
  final files = [
    'lib/app/modules/merchant/views/merchant_home_page.dart',
    'lib/app/modules/merchant/views/merchant_main_page.dart'
  ];

  for (final path in files) {
    final file = File(path);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      // Replace all instances of `GoogleFonts.inter(` with `primaryTextStyle.copyWith(`
      content = content.replaceAll(
          'GoogleFonts.inter(', 'primaryTextStyle.copyWith(');

      // Also need to remove the GoogleFonts import if exists
      content = content.replaceAll(
          "import 'package:google_fonts/google_fonts.dart';", "");

      file.writeAsStringSync(content);
      print('Replaced GoogleFonts in $path');
    }
  }
}
