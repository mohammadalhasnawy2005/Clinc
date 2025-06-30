import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/config/api_config.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/doctor_model.dart';

class BookingDoctorInfo extends StatelessWidget {
  final DoctorModel doctor;

  const BookingDoctorInfo({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          // Doctor Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: CachedNetworkImage(
                imageUrl: ApiConfig.getImageUrl(doctor.imageName),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.gray200,
                  child: const Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: AppColors.textLight,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.gray200,
                  child: const Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Doctor Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  doctor.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Specialization
                Text(
                  doctor.specialization.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),

                const SizedBox(height: 8),

                // Location & Package
                Row(
                  children: [
                    // Location
                    Icon(
                      Icons.location_on_rounded,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.iraqiProvinceName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),

                    // Package Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            AppUtils.getPackageColor(doctor.subscriptionRank),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppUtils.getPackageNameText(doctor.subscriptionRank),
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
