import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../controllers/general_controller.dart';
import '../../../controllers/doctor_controller.dart';
import 'specialization_card.dart';

class SpecializationsSection extends StatelessWidget {
  const SpecializationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final GeneralController generalController = Get.find<GeneralController>();
    final DoctorController doctorController = Get.find<DoctorController>();

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.specializations,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: الانتقال لصفحة جميع التخصصات
                },
                child: Text(
                  AppStrings.viewAll,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Specializations Grid
          Obx(() {
            if (generalController.specializations.isEmpty) {
              return const _LoadingSpecializations();
            }

            // عرض أول 8 تخصصات فقط
            final displaySpecializations =
                generalController.specializations.take(8).toList();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: displaySpecializations.length,
              itemBuilder: (context, index) {
                final specialization = displaySpecializations[index];
                return SpecializationCard(
                  specialization: specialization,
                  onTap: () {
                    doctorController
                        .applySpecializationFilter(specialization.id);
                    // TODO: الانتقال لصفحة الأطباء المفلترة
                  },
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _LoadingSpecializations extends StatelessWidget {
  const _LoadingSpecializations();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}
