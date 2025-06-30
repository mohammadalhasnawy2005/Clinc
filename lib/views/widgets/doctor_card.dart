import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/config/api_config.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/doctor_model.dart';

class DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final VoidCallback onTap;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
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
            // Doctor Image
            Container(
              height: 120,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
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

            // Doctor Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      doctor.name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

                    const Spacer(),

                    // Subscription Badge & Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Subscription Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppUtils.getPackageColor(
                                doctor.subscriptionRank),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppUtils.getPackageNameText(
                                doctor.subscriptionRank),
                            style: const TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Location Icon
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
