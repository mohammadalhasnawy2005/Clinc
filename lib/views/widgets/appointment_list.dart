import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/appointment_controller.dart';
import '../../controllers/auth_controller.dart';
import 'appointment_item.dart';

class AppointmentList extends StatelessWidget {
  const AppointmentList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // التأكد من وجود Controllers
      if (!Get.isRegistered<AppointmentController>()) {
        Get.put(AppointmentController(), permanent: false);
      }
      if (!Get.isRegistered<AuthController>()) {
        Get.put(AuthController(), permanent: true);
      }

      final appointmentController = AppointmentController.instance;
      final authController = AuthController.instance;

      if (appointmentController.isLoadingAppointments.value) {
        return const _LoadingAppointments();
      }

      final appointments = authController.isPatient
          ? _getFilteredPatientAppointments(appointmentController)
          : _getFilteredDoctorAppointments(appointmentController);

      if (appointments.isEmpty) {
        return _EmptyAppointments(
          isDoctor: authController.isDoctor,
          statusFilter: appointmentController.statusFilter.value,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppointmentItem(
              appointment: appointment,
              isDoctor: authController.isDoctor,
              onTap: () {
                appointmentController.selectAppointment(appointment);
                // Get.toNamed('/appointment-details');
                _showAppointmentDetails(context, appointment);
              },
            ),
          );
        },
      );
    });
  }

  List<dynamic> _getFilteredPatientAppointments(
      AppointmentController controller) {
    if (controller.statusFilter.value == -1) {
      return controller.myAppointments;
    }
    return controller.getAppointmentsByStatus(controller.statusFilter.value);
  }

  List<dynamic> _getFilteredDoctorAppointments(
      AppointmentController controller) {
    if (controller.statusFilter.value == -1) {
      return controller.doctorAppointments;
    }
    return controller.getAppointmentsByStatus(controller.statusFilter.value);
  }

  void _showAppointmentDetails(BuildContext context, appointment) {
    Get.dialog(
      AlertDialog(
        title: const Text('تفاصيل الموعد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المريض: ${appointment.user.name}'),
            Text('الطبيب: ${appointment.doctor.name}'),
            Text('التاريخ: ${appointment.appointmentDate}'),
            Text('الحالة: ${appointment.status}'),
            if (appointment.notes != null && appointment.notes!.isNotEmpty)
              Text('الملاحظات: ${appointment.notes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}

class _LoadingAppointments extends StatelessWidget {
  const _LoadingAppointments();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  final bool isDoctor;
  final int statusFilter;

  const _EmptyAppointments({
    required this.isDoctor,
    required this.statusFilter,
  });

  @override
  Widget build(BuildContext context) {
    final String message = _getEmptyMessage();
    final IconData icon = _getEmptyIcon();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isDoctor ? 'ستظهر هنا مواعيد مرضاك' : 'ابدأ بحجز موعدك الأول',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyMessage() {
    if (statusFilter == -1) {
      return isDoctor ? 'لا توجد مواعيد في العيادة' : 'لا توجد مواعيد محجوزة';
    }

    switch (statusFilter) {
      case 0:
        return 'لا توجد مواعيد قيد الانتظار';
      case 1:
        return 'لا توجد مواعيد موافق عليها';
      case 2:
        return 'لا توجد مواعيد مرفوضة';
      case 3:
        return 'لا توجد مواعيد مكتملة';
      default:
        return 'لا توجد مواعيد';
    }
  }

  IconData _getEmptyIcon() {
    switch (statusFilter) {
      case 0:
        return Icons.schedule_rounded;
      case 1:
        return Icons.check_circle_outline_rounded;
      case 2:
        return Icons.cancel_outlined;
      case 3:
        return Icons.history_rounded;
      default:
        return Icons.calendar_today_outlined;
    }
  }
}
