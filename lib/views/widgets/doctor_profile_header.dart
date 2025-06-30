import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/config/api_config.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/doctor_model.dart';

class DoctorProfileHeader extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorProfileHeader({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        children: [
          // Doctor Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: ApiConfig.getImageUrl(doctor.imageName),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.gray200,
                  child: const Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: AppColors.textLight,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.gray200,
                  child: const Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: AppColors.textLight,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Doctor Name
          Text(
            doctor.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Specialization
          Text(
            doctor.specialization.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Subscription Badge & Location
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Subscription Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppUtils.getPackageColor(doctor.subscriptionRank),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.textWhite,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppUtils.getPackageNameText(doctor.subscriptionRank),
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Location
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    doctor.iraqiProvinceName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
