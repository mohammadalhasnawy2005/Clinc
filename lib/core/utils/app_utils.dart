import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../constants/app_colors.dart';

class AppUtils {
  AppUtils._();

  // Validation Methods
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!RegExp(AppConstants.emailPattern).hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (!RegExp(AppConstants.phonePattern).hasMatch(value)) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'كلمة المرور يجب أن تكون ${AppConstants.minPasswordLength} أحرف على الأقل';
    }
    if (value.length > AppConstants.maxPasswordLength) {
      return 'كلمة المرور طويلة جداً';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }
    if (value.length < AppConstants.minNameLength) {
      return 'الاسم قصير جداً';
    }
    if (value.length > AppConstants.maxNameLength) {
      return 'الاسم طويل جداً';
    }
    if (!RegExp(AppConstants.namePattern).hasMatch(value)) {
      return 'الاسم يحتوي على أحرف غير صحيحة';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (value != password) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  // Date & Time Formatting
  static String formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'ar').format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm', 'ar').format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy/MM/dd HH:mm', 'ar').format(dateTime);
  }

  static String formatDateTimeFromString(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return formatDateTime(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime);
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'منذ قليل';
    }
  }

  // Status Helper Methods
  static String getAppointmentStatusText(int status) {
    switch (status) {
      case AppConstants.appointmentStatusPending:
        return 'قيد الانتظار';
      case AppConstants.appointmentStatusApproved:
        return 'موافق عليه';
      case AppConstants.appointmentStatusRejected:
        return 'مرفوض';
      case AppConstants.appointmentStatusCompleted:
        return 'مكتمل';
      default:
        return 'غير معروف';
    }
  }

  static Color getAppointmentStatusColor(int status) {
    switch (status) {
      case AppConstants.appointmentStatusPending:
        return AppColors.pending;
      case AppConstants.appointmentStatusApproved:
        return AppColors.approved;
      case AppConstants.appointmentStatusRejected:
        return AppColors.rejected;
      case AppConstants.appointmentStatusCompleted:
        return AppColors.completed;
      default:
        return AppColors.gray500;
    }
  }

  static String getPaymentStatusText(int status) {
    switch (status) {
      case AppConstants.paymentStatusUnpaid:
        return 'لم يُدفع';
      case AppConstants.paymentStatusPaidOnline:
        return 'مدفوع إلكترونياً';
      case AppConstants.paymentStatusPaidInClinic:
        return 'مدفوع في العيادة';
      default:
        return 'غير معروف';
    }
  }

  static Color getPaymentStatusColor(int status) {
    switch (status) {
      case AppConstants.paymentStatusUnpaid:
        return AppColors.error;
      case AppConstants.paymentStatusPaidOnline:
      case AppConstants.paymentStatusPaidInClinic:
        return AppColors.success;
      default:
        return AppColors.gray500;
    }
  }

  static String getPackageNameText(int packageId) {
    switch (packageId) {
      case AppConstants.packageBasic:
        return 'أساسي';
      case AppConstants.packageGold:
        return 'ذهبي';
      case AppConstants.packageDiamond:
        return 'ألماس';
      case AppConstants.packagePremium:
        return 'فاخر';
      default:
        return 'غير معروف';
    }
  }

  static Color getPackageColor(int packageId) {
    switch (packageId) {
      case AppConstants.packageBasic:
        return AppColors.packageBasic;
      case AppConstants.packageGold:
        return AppColors.packageGold;
      case AppConstants.packageDiamond:
        return AppColors.packageDiamond;
      case AppConstants.packagePremium:
        return AppColors.packagePremium;
      default:
        return AppColors.gray500;
    }
  }

  static String getDayNameText(int dayId) {
    switch (dayId) {
      case AppConstants.daySaturday:
        return 'السبت';
      case AppConstants.daySunday:
        return 'الأحد';
      case AppConstants.dayMonday:
        return 'الاثنين';
      case AppConstants.dayTuesday:
        return 'الثلاثاء';
      case AppConstants.dayWednesday:
        return 'الأربعاء';
      case AppConstants.dayThursday:
        return 'الخميس';
      case AppConstants.dayFriday:
        return 'الجمعة';
      default:
        return 'غير معروف';
    }
  }

  // Snackbar Methods
  static void showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.success,
      colorText: AppColors.textWhite,
      icon: const Icon(Icons.check_circle, color: AppColors.textWhite),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      borderRadius: AppConstants.defaultBorderRadius,
    );
  }

  static void showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.textWhite,
      icon: const Icon(Icons.error, color: AppColors.textWhite),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      borderRadius: AppConstants.defaultBorderRadius,
    );
  }

  static void showWarningSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.warning,
      colorText: AppColors.textWhite,
      icon: const Icon(Icons.warning, color: AppColors.textWhite),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      borderRadius: AppConstants.defaultBorderRadius,
    );
  }

  static void showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.info,
      colorText: AppColors.textWhite,
      icon: const Icon(Icons.info, color: AppColors.textWhite),
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      borderRadius: AppConstants.defaultBorderRadius,
    );
  }

  // Loading Dialog
  static void showLoadingDialog() {
    Get.dialog(
      const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(AppConstants.largePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: AppConstants.defaultPadding),
                Text('جاري التحميل...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoadingDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  // Price Formatting
  static String formatPrice(double price) {
    if (price == 0) {
      return 'مجاني';
    }
    final formatter = NumberFormat.currency(
      locale: 'ar',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  // URL Validation
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Log Methods (للتطوير)
  static void logInfo(String message) {
    debugPrint('ℹ️ INFO: $message');
  }

  static void logWarning(String message) {
    debugPrint('⚠️ WARNING: $message');
  }

  static void logError(String message, [dynamic error]) {
    debugPrint('❌ ERROR: $message');
    if (error != null) {
      debugPrint('❌ ERROR DETAILS: $error');
    }
  }
}
