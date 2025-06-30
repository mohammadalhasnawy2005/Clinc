import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../controllers/appointment_controller.dart';

class AppointmentsFilterTabs extends StatelessWidget {
  const AppointmentsFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final AppointmentController controller = Get.find<AppointmentController>();

    final List<FilterTab> tabs = [
      FilterTab(status: -1, label: 'الكل'),
      FilterTab(
          status: AppConstants.appointmentStatusPending, label: 'قيد الانتظار'),
      FilterTab(
          status: AppConstants.appointmentStatusApproved, label: 'موافق عليها'),
      FilterTab(
          status: AppConstants.appointmentStatusCompleted, label: 'مكتملة'),
      FilterTab(
          status: AppConstants.appointmentStatusRejected, label: 'مرفوضة'),
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];

          return Obx(() {
            final isSelected = controller.statusFilter.value == tab.status;
            final appointmentCount = tab.status == -1
                ? controller.myAppointments.length
                : controller.getAppointmentCountByStatus(tab.status);

            return GestureDetector(
              onTap: () => controller.applyStatusFilter(tab.status),
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tab.label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.textWhite
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    if (appointmentCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.textWhite.withOpacity(0.2)
                              : _getStatusColor(tab.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          appointmentCount.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.textWhite
                                : _getStatusColor(tab.status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case AppConstants.appointmentStatusPending:
        return AppColors.warning;
      case AppConstants.appointmentStatusApproved:
        return AppColors.success;
      case AppConstants.appointmentStatusCompleted:
        return AppColors.info;
      case AppConstants.appointmentStatusRejected:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}

class FilterTab {
  final int status;
  final String label;

  FilterTab({
    required this.status,
    required this.label,
  });
}
