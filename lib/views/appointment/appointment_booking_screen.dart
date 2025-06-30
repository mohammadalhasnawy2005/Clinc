import 'package:clinic/views/widgets/booking_date_picker.dart';
import 'package:clinic/views/widgets/booking_doctor_info.dart';
import 'package:clinic/views/widgets/booking_notes_section.dart';
import 'package:clinic/views/widgets/booking_summary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../controllers/appointment_controller.dart';
import '../../controllers/auth_controller.dart';

class AppointmentBookingScreen extends StatelessWidget {
  const AppointmentBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppointmentController appointmentController =
        Get.find<AppointmentController>();
    final AuthController authController = Get.find<AuthController>();

    // التحقق من تسجيل الدخول
    if (!authController.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/login');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.bookAppointment),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        final selectedDoctor = appointmentController.selectedDoctor.value;

        if (selectedDoctor == null) {
          return const Center(
            child: Text('يرجى اختيار طبيب أولاً'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Doctor Info
              BookingDoctorInfo(doctor: selectedDoctor),

              const SizedBox(height: 20),

              // Date Picker
              BookingDatePicker(doctorId: selectedDoctor.id),

              const SizedBox(height: 20),

              // Notes Section
              const BookingNotesSection(),

              const SizedBox(height: 20),

              // Booking Summary
              const BookingSummary(),

              const SizedBox(height: 100), // للـ Bottom Navigation
            ],
          ),
        );
      }),
    );
  }
}
