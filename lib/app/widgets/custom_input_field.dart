import 'package:flutter/material.dart';
import '../../theme.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool initialObscureText;
  final dynamic icon;
  final bool showVisibilityToggle;
  final bool readOnly;
  final int? maxLines;
  final TextInputType? keyboardType;
  final VoidCallback? onVisibilityToggle;
  final Function(String)? onChanged;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    this.initialObscureText = false,
    required this.icon,
    this.showVisibilityToggle = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.onVisibilityToggle,
    this.onChanged,
  }) : assert(!initialObscureText || (maxLines == null || maxLines == 1),
            'Obscured fields cannot be multiline.');

  @override
  // ignore: library_private_types_in_public_api
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _obscureText;
  bool _isFocused = false;
  bool _hasText = false;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.initialObscureText;
    _hasText = widget.controller.text.isNotEmpty;
    _focusNode = FocusNode();
    _focusNode!.addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(CustomInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleTextChange);
      widget.controller.addListener(_handleTextChange);
      _hasText = widget.controller.text.isNotEmpty;
    }
    if (widget.initialObscureText != oldWidget.initialObscureText) {
      _obscureText = widget.initialObscureText;
    }
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode!.hasFocus;
      });
    }
  }

  void _handleTextChange() {
    if (mounted) {
      setState(() {
        _hasText = widget.controller.text.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    _focusNode?.removeListener(_handleFocusChange);
    _focusNode?.dispose();
    _focusNode = null;
    super.dispose();
  }

  void _toggleVisibility() {
    if (mounted) {
      setState(() {
        _obscureText = !_obscureText;
      });
      widget.onVisibilityToggle?.call();
    }
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
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.error,
            size: 18,
            color: color,
          ),
        ),
      );
    } else if (widget.icon is IconData) {
      return Icon(
        widget.icon as IconData,
        size: 18,
        color: color,
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
      margin: const EdgeInsets.only(top: 10),
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
            height: widget.maxLines != null && widget.maxLines! > 1
                ? 50.0 * widget.maxLines!
                : 50.0,
            decoration: BoxDecoration(
              color: widget.readOnly
                  ? backgroundColor2.withOpacity(0.7)
                  : backgroundColor2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (_isFocused || _hasText)
                    ? logoColorSecondary
                    : Colors.grey.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment:
                  widget.maxLines != null && widget.maxLines! > 1
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    top: widget.maxLines != null && widget.maxLines! > 1
                        ? 16
                        : 0,
                  ),
                  child: _buildIcon(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    focusNode: _focusNode,
                    style: primaryTextStyle,
                    obscureText: _obscureText,
                    controller: widget.controller,
                    validator: widget.validator,
                    maxLines: widget.initialObscureText ? 1 : widget.maxLines,
                    keyboardType: widget.keyboardType,
                    readOnly: widget.readOnly,
                    onChanged: widget.onChanged,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: subtitleTextStyle,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.only(
                        top: widget.maxLines != null && widget.maxLines! > 1
                            ? 16
                            : 0,
                      ),
                    ),
                  ),
                ),
                if (widget.showVisibilityToggle)
                  GestureDetector(
                    onTap: _toggleVisibility,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 16,
                        top: widget.maxLines != null && widget.maxLines! > 1
                            ? 16
                            : 0,
                      ),
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
