import 'package:antarkanma_merchant/theme.dart';
import 'package:flutter/material.dart';

class SearchInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;
  final Function(String)? onChanged;
  final FocusNode? focusNode;

  const SearchInputField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.onClear,
    this.onChanged,
    this.focusNode,
  }) : super(key: key);

  @override
  State<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends State<SearchInputField> {
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
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

  Widget _buildIcon() {
    final color = (_isFocused || _hasText) ? logoColorSecondary : Colors.grey;
    return Icon(
      Icons.search_outlined,
      size: Dimenssions.iconSize20,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoColor = (_isFocused || _hasText)
        ? logoColorSecondary
        : Colors.grey.withOpacity(0.5);
    return Container(
      height: Dimenssions.height45,
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(Dimenssions.radius12),
        border: Border.all(
          color: logoColor,
          width: 1.85,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: Dimenssions.width15),
          _buildIcon(),
          SizedBox(width: Dimenssions.width8),
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() {
                  _isFocused = hasFocus;
                });
              },
              child: TextFormField(
                style: primaryTextStyle.copyWith(fontSize: Dimenssions.font14),
                controller: widget.controller,
                focusNode: widget.focusNode,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle:
                      subtitleTextStyle.copyWith(fontSize: Dimenssions.font14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isCollapsed: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: Dimenssions.height5),
                ),
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: widget.onClear,
              child: Padding(
                padding: EdgeInsets.only(right: Dimenssions.width10),
                child: Icon(
                  Icons.close,
                  size: Dimenssions.iconSize20,
                  color: (_isFocused || _hasText)
                      ? logoColorSecondary
                      : Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
