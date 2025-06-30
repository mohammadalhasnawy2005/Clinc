import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../controllers/appointment_controller.dart';
import '../../../controllers/doctor_controller.dart';

class BookingDatePicker extends StatelessWidget {
  final int doctorId;

  const BookingDatePicker({
    super.key,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    final AppointmentController appointmentController =
        Get.find<AppointmentController>();
    final DoctorController doctorController = Get.find<DoctorController>();

    return Container(
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
            AppStrings.selectDate,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          // Available Days
          Obx(() {
            if (doctorController.doctorAvailability.isEmpty) {
              return const _NoAvailableDays();
            }

            return Column(
              children: doctorController.doctorAvailability.map((availability) {
                final dayName = AppUtils.getDayNameText(availability.dayId);
                final isSelected =
                    appointmentController.selectedDate.value?.weekday ==
                        _getWeekdayFromDayId(availability.dayId);

                return GestureDetector(
                  onTap: () {
                    final selectedDate = _getNextDateForDay(availability.dayId);
                    appointmentController.selectDateForBooking(selectedDate);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Day Name
                        Expanded(
                          flex: 2,
                          child: Text(
                            dayName,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                          ),
                        ),

                        // Working Hours
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${availability.startTime} - ${availability.endTime}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                          ),
                        ),

                        // Selection Icon
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 16),

          // Selected Date Display
          Obx(() {
            final selectedDate = appointmentController.selectedDate.value;
            if (selectedDate == null) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'التاريخ المختار: ${AppUtils.formatDate(selectedDate)}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  int _getWeekdayFromDayId(int dayId) {
    // تحويل dayId إلى weekday
    switch (dayId) {
      case 1:
        return DateTime.saturday;
      case 2:
        return DateTime.sunday;
      case 3:
        return DateTime.monday;
      case 4:
        return DateTime.tuesday;
      case 5:
        return DateTime.wednesday;
      case 6:
        return DateTime.thursday;
      case 7:
        return DateTime.friday;
      default:
        return DateTime.saturday;
    }
  }

  DateTime _getNextDateForDay(int dayId) {
    final today = DateTime.now();
    final targetWeekday = _getWeekdayFromDayId(dayId);

    int daysToAdd = (targetWeekday - today.weekday) % 7;
    if (daysToAdd == 0) daysToAdd = 7; // الأسبوع القادم

    return today.add(Duration(days: daysToAdd));
  }
}

class _NoAvailableDays extends StatelessWidget {
  const _NoAvailableDays();

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
          'لا توجد أيام متاحة للحجز',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
