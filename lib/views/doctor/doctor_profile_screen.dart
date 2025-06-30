import 'package:clinic/views/widgets/doctor_actions_section.dart';
import 'package:clinic/views/widgets/doctor_availability_section.dart';
import 'package:clinic/views/widgets/doctor_info_section.dart';
import 'package:clinic/views/widgets/doctor_profile_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/doctor_controller.dart';
import '../../controllers/auth_controller.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DoctorController doctorController = Get.find<DoctorController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ملف الطبيب'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        final doctor = doctorController.selectedDoctor.value;

        if (doctor == null) {
          return const Center(
            child: Text('لم يتم العثور على بيانات الطبيب'),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Doctor Header
              DoctorProfileHeader(doctor: doctor),

              // Doctor Info
              DoctorInfoSection(doctor: doctor),

              // Doctor Availability
              DoctorAvailabilitySection(doctorId: doctor.id),

              // Actions (Book Appointment, Message, etc.)
              if (authController.isPatient)
                DoctorActionsSection(doctor: doctor),

              const SizedBox(height: 100), // للـ Bottom Navigation
            ],
          ),
        );
      }),
    );
  }
}
