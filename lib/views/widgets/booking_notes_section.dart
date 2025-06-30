import 'package:clinic/views/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../controllers/appointment_controller.dart';

class BookingNotesSection extends StatelessWidget {
  const BookingNotesSection({super.key});

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
            'ملاحظات إضافية',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'اكتب أي ملاحظات أو أعراض تريد إخبار الطبيب بها (اختياري)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),

          const SizedBox(height: 16),

          // Notes Text Field
          CustomTextField(
            controller: appointmentController.notesController,
            labelText: 'الملاحظات',
            hintText: 'اكتب ملاحظاتك هنا...',
            maxLines: 4,
            maxLength: 500,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
          ),

          const SizedBox(height: 12),

          // Helper Text
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.info,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ستساعد هذه المعلومات الطبيب في تحضير الاستشارة بشكل أفضل',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
