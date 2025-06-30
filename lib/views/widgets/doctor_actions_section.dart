import 'package:clinic/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/doctor_model.dart';
import '../../../controllers/appointment_controller.dart';

class DoctorActionsSection extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorActionsSection({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    final AppointmentController appointmentController =
        Get.put(AppointmentController());

    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary Action - Book Appointment
          CustomButton(
            text: AppStrings.bookAppointment,
            icon: Icons.calendar_today_rounded,
            onPressed: () {
              appointmentController.selectDoctorForBooking(doctor);
              Get.toNamed('/appointment-booking');
            },
          ),

          const SizedBox(height: 12),

          // Secondary Actions Row
          Row(
            children: [
              // Call Button
              Expanded(
                child: CustomButton(
                  text: 'اتصال',
                  icon: Icons.phone_rounded,
                  type: ButtonType.outline,
                  onPressed: () {
                    _showCallDialog(context, doctor.phoneNumber);
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Message Button (if available)
              Expanded(
                child: CustomButton(
                  text: AppStrings.sendMessage,
                  icon: Icons.message_rounded,
                  type: ButtonType.secondary,
                  onPressed: () {
                    // TODO: فتح المحادثة (للمستقبل)
                    Get.snackbar(
                      'قريباً',
                      'ميزة المحادثة ستكون متاحة قريباً',
                      backgroundColor: AppColors.info,
                      colorText: AppColors.textWhite,
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Location Button
          CustomButton(
            text: 'عرض الموقع',
            icon: Icons.location_on_rounded,
            type: ButtonType.outline,
            onPressed: () {
              _showLocationDialog(context, doctor.location);
            },
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context, String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الاتصال بالطبيب'),
        content: Text('هل تريد الاتصال بـ $phoneNumber؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: فتح تطبيق الهاتف
            },
            child: const Text('اتصال'),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context, String location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('موقع العيادة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location),
            const SizedBox(height: 16),
            const Text(
              'هل تريد فتح الموقع في الخرائط؟',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: فتح في خرائط Google
            },
            child: const Text('فتح الخرائط'),
          ),
        ],
      ),
    );
  }
}
