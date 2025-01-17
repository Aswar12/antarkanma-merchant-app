// ignore_for_file: library_private_types_in_public_api

import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool initialObscureText;
  final dynamic icon;
  final bool showVisibilityToggle;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    this.initialObscureText = false,
    required this.icon,
    this.showVisibilityToggle = false,
  });

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _obscureText;
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.initialObscureText;
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_updateHasText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateHasText);
    super.dispose();
  }

  void _updateHasText() {
    setState(() {
      _hasText = widget.controller.text.isNotEmpty;
    });
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget _buildIcon() {
    final color = (_isFocused || _hasText) ? logoColorSecondary : Colors.grey;

    if (widget.icon is String) {
      return SizedBox(
        width: 18,
        height: 18,
        child: Image.asset(
          widget.icon as String,
          color: color,
        ),
      );
    } else if (widget.icon is Icon) {
      final Icon originalIcon = widget.icon as Icon;
      return Icon(
        originalIcon.icon,
        size: 18,
        color: color,
      );
    }

    return Icon(
      Icons.error,
      size: 18,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10), // Reduced margin
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: primaryTextStyle.copyWith(
              fontSize: 16,
              fontWeight: medium,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: backgroundColor2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (_isFocused || _hasText)
                    ? logoColorSecondary
                    : Colors.grey.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 16),
                _buildIcon(),
                SizedBox(width: 16),
                Expanded(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {
                        _isFocused = hasFocus;
                      });
                    },
                    child: TextFormField(
                      style: primaryTextStyle,
                      obscureText: _obscureText,
                      controller: widget.controller,
                      validator: widget.validator,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: subtitleTextStyle,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ),
                if (widget.showVisibilityToggle)
                  GestureDetector(
                    onTap: _toggleVisibility,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: (_isFocused || _hasText)
                            ? logoColorSecondary
                            : Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
