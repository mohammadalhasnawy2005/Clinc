import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/config/api_config.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/doctor_model.dart';

class NearbyDoctorItem extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;

  const NearbyDoctorItem({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Doctor Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: CachedNetworkImage(
                  imageUrl: ApiConfig.getImageUrl(doctor.imageName),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.gray200,
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.textLight,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.gray200,
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Doctor Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Subscription
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doctor.name,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              AppUtils.getPackageColor(doctor.subscriptionRank),
                          borderRadius: BorderRadius.circular(8),
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

                  const SizedBox(height: 4),

                  // Specialization
                  Text(
                    doctor.specialization.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          doctor.iraqiProvinceName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textLight,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow Icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
