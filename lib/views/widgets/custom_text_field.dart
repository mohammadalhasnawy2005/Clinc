import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final bool isEnabled;
  final bool isReadOnly;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.isEnabled = true,
    this.isReadOnly = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.onTap,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.labelText,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),

        const SizedBox(height: 8),

        // Text Field
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _isObscured : false,
            enabled: widget.isEnabled,
            readOnly: widget.isReadOnly,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            autofocus: widget.autofocus,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: widget.isEnabled
                      ? AppColors.textPrimary
                      : AppColors.textLight,
                ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color:
                          _isFocused ? AppColors.primary : AppColors.textLight,
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                      icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                    )
                  : widget.suffixIcon,
              filled: true,
              fillColor: widget.isEnabled
                  ? AppColors.backgroundLight
                  : AppColors.gray100,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                borderSide: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                borderSide: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                borderSide: BorderSide(
                  color: AppColors.error,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.defaultBorderRadius),
                borderSide: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.defaultPadding,
              ),
              counterText: '', // إخفاء عداد الأحرف
            ),
          ),
        ),
      ],
    );
  }
}
