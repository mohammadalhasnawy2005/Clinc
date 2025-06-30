import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/config/api_config.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/appointment_model.dart';

class AppointmentItem extends StatelessWidget {
  final AppointmentModel appointment;
  final bool isDoctor;
  final VoidCallback onTap;

  const AppointmentItem({
    super.key,
    required this.appointment,
    required this.isDoctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName =
        isDoctor ? appointment.user.name : appointment.doctor.name;
    final String imageName = isDoctor
        ? '' // المريض ليس له صورة في API
        : appointment.doctor.imageName;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(
            color: AppUtils.getAppointmentStatusColor(appointment.status)
                .withOpacity(0.3),
            width: 1,
          ),
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
            // Header Row
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: imageName.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: ApiConfig.getImageUrl(imageName),
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                _buildAvatarPlaceholder(),
                            errorWidget: (context, url, error) =>
                                _buildAvatarPlaceholder(),
                          )
                        : _buildAvatarPlaceholder(),
                  ),
                ),

                const SizedBox(width: 12),

                // Name & Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppUtils.getAppointmentStatusColor(
                                  appointment.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppUtils.getAppointmentStatusText(appointment.status),
                          style: TextStyle(
                            color: AppUtils.getAppointmentStatusColor(
                                appointment.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textLight,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Appointment Info
            Row(
              children: [
                // Date
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppUtils.formatDate(appointment.appointmentDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),

                // Payment Status
                if (appointment.paymentAmount > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.payment_rounded,
                        size: 16,
                        color: AppUtils.getPaymentStatusColor(
                            appointment.paymentStatus),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppUtils.formatPrice(appointment.paymentAmount),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppUtils.getPaymentStatusColor(
                                  appointment.paymentStatus),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
              ],
            ),

            // Time Status
            if (appointment.isUpcoming) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment.timeUntilText,
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.gray200,
      child: Icon(
        isDoctor ? Icons.person_rounded : Icons.medical_services_rounded,
        color: AppColors.textLight,
        size: 24,
      ),
    );
  }
}
