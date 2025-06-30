import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonType type;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = ButtonType.primary,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPress = isEnabled && !isLoading && onPressed != null;

    switch (type) {
      case ButtonType.primary:
        return _buildElevatedButton(context, canPress);
      case ButtonType.secondary:
        return _buildSecondaryButton(context, canPress);
      case ButtonType.outline:
        return _buildOutlinedButton(context, canPress);
      case ButtonType.text:
        return _buildTextButton(context, canPress);
    }
  }

  Widget _buildElevatedButton(BuildContext context, bool canPress) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: canPress ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? AppColors.textWhite,
          disabledBackgroundColor: AppColors.gray300,
          disabledForegroundColor: AppColors.textLight,
          elevation: canPress ? 2 : 0,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppConstants.defaultBorderRadius,
            ),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.defaultPadding,
              ),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, bool canPress) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: canPress ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryLight,
          foregroundColor: textColor ?? AppColors.primary,
          disabledBackgroundColor: AppColors.gray200,
          disabledForegroundColor: AppColors.textLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppConstants.defaultBorderRadius,
            ),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.defaultPadding,
              ),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context, bool canPress) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: OutlinedButton(
        onPressed: canPress ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          disabledForegroundColor: AppColors.textLight,
          side: BorderSide(
            color: canPress
                ? (backgroundColor ?? AppColors.primary)
                : AppColors.border,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppConstants.defaultBorderRadius,
            ),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.defaultPadding,
              ),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildTextButton(BuildContext context, bool canPress) {
    return SizedBox(
      width: width,
      height: height ?? 40,
      child: TextButton(
        onPressed: canPress ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
          disabledForegroundColor: AppColors.textLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppConstants.smallBorderRadius,
            ),
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.smallPadding,
                vertical: AppConstants.smallPadding,
              ),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.primary
                    ? AppColors.textWhite
                    : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'جاري التحميل...',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

// Specialized Button Widgets للاستخدام السريع

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      type: ButtonType.primary,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      type: ButtonType.secondary,
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const OutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      type: ButtonType.outline,
    );
  }
}
