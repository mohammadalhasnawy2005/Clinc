import 'package:clinic/views/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../controllers/appointment_controller.dart';

class BookingSummary extends StatelessWidget {
  const BookingSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final AppointmentController appointmentController =
        Get.find<AppointmentController>();

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
            'ملخص الحجز',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          // Summary Details
          Obx(() {
            final selectedDoctor = appointmentController.selectedDoctor.value;
            final selectedDate = appointmentController.selectedDate.value;

            return Column(
              children: [
                // Doctor
                if (selectedDoctor != null)
                  _buildSummaryRow(
                    context,
                    icon: Icons.person_rounded,
                    label: 'الطبيب',
                    value: selectedDoctor.name,
                  ),

                const SizedBox(height: 12),

                // Date
                if (selectedDate != null)
                  _buildSummaryRow(
                    context,
                    icon: Icons.calendar_today_rounded,
                    label: 'التاريخ',
                    value: AppUtils.formatDate(selectedDate),
                  ),

                const SizedBox(height: 12),

                // Status
                _buildSummaryRow(
                  context,
                  icon: Icons.schedule_rounded,
                  label: 'الحالة',
                  value: 'قيد الانتظار (48 ساعة للموافقة)',
                ),

                const SizedBox(height: 12),

                // Payment
                _buildSummaryRow(
                  context,
                  icon: Icons.payment_rounded,
                  label: 'الدفع',
                  value: 'في العيادة (يحدد الطبيب المبلغ)',
                ),
              ],
            );
          }),

          const SizedBox(height: 20),

          // Confirm Button
          Obx(() {
            final canBook = appointmentController.canBookAppointment();

            return CustomButton(
              text: AppStrings.confirmBooking,
              onPressed:
                  canBook ? () => _confirmBooking(appointmentController) : null,
              isLoading: appointmentController.isCreatingAppointment.value,
              isEnabled: canBook,
            );
          }),

          const SizedBox(height: 12),

          // Terms Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'بالضغط على تأكيد الحجز، أنت توافق على شروط وأحكام الخدمة',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmBooking(AppointmentController controller) {
    final doctor = controller.selectedDoctor.value;
    final date = controller.selectedDate.value;

    if (doctor != null && date != null) {
      controller.createAppointment(
        doctorId: doctor.id,
        appointmentDate: date,
        notes: controller.notesController.text.trim().isNotEmpty
            ? controller.notesController.text.trim()
            : null,
      );
    }
  }
}
