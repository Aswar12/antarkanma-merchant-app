import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Only process if the string contains digits
    if (newValue.text.contains(RegExp(r'[0-9]'))) {
      // Remove all non-digit characters
      String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      
      if (digitsOnly.isEmpty) return newValue;

      // Parse the number and format it
      // Convert to double to preserve actual value
      double value = double.parse(digitsOnly);
      String formatted = _formatter.format(value);

      // Ensure cursor position is correct
      int selectionIndex = formatted.length;
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: selectionIndex),
      );
    }

    return newValue;
  }

  // Helper method to get actual numeric value
  static double getNumericValue(String text) {
    String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.isEmpty ? 0 : double.parse(digitsOnly);
  }
}
