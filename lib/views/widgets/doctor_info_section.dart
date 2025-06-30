import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/doctor_model.dart';

class DoctorInfoSection extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorInfoSection({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            AppStrings.aboutDoctor,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 16),

          // Description
          if (doctor.description.isNotEmpty) ...[
            Text(
              doctor.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 16),
          ],

          // Doctor Details
          _buildInfoRow(
            context,
            icon: Icons.phone_rounded,
            label: 'رقم الهاتف',
            value: doctor.phoneNumber,
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            context,
            icon: Icons.location_on_rounded,
            label: 'العنوان',
            value: doctor.location,
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            context,
            icon: Icons.medical_services_rounded,
            label: 'التخصص',
            value: doctor.specialization.name,
          ),

          const SizedBox(height: 12),

          _buildInfoRow(
            context,
            icon: Icons.calendar_today_rounded,
            label: 'تاريخ الميلاد',
            value: doctor.birthDay.isNotEmpty ? doctor.birthDay : 'غير محدد',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
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
              const SizedBox(height: 2),
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
}
