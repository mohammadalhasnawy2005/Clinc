import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../controllers/doctor_controller.dart';

class DoctorAvailabilitySection extends StatelessWidget {
  final int doctorId;

  const DoctorAvailabilitySection({
    super.key,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    final DoctorController doctorController = Get.find<DoctorController>();

    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            AppStrings.workingHours,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          // Availability List
          Obx(() {
            if (doctorController.isLoadingAvailability.value) {
              return const _LoadingAvailability();
            }

            if (doctorController.doctorAvailability.isEmpty) {
              return const _EmptyAvailability();
            }

            return Column(
              children: doctorController.doctorAvailability.map((availability) {
                final dayName = AppUtils.getDayNameText(availability.dayId);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Day
                      Expanded(
                        flex: 2,
                        child: Text(
                          dayName,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                        ),
                      ),

                      // Time
                      Expanded(
                        flex: 3,
                        child: Text(
                          '${availability.startTime} - ${availability.endTime}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),

                      // Max Appointments
                      Text(
                        '${availability.maxAppointments} موعد',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _LoadingAvailability extends StatelessWidget {
  const _LoadingAvailability();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _EmptyAvailability extends StatelessWidget {
  const _EmptyAvailability();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'لم يتم تحديد أوقات العمل بعد',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
