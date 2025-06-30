import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../controllers/doctor_controller.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final DoctorController doctorController = Get.find<DoctorController>();

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Input
          Expanded(
            child: TextField(
              controller: doctorController.searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchDoctors,
                hintStyle: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textLight,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: 14,
                ),
              ),
              onTap: () {
                // الانتقال لصفحة البحث المتقدمة
                _showSearchBottomSheet(context, doctorController);
              },
              readOnly: true, // للانتقال لصفحة البحث فقط
            ),
          ),

          // Filter Button
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius:
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            child: IconButton(
              onPressed: () {
                _showFilterBottomSheet(context, doctorController);
              },
              icon: const Icon(
                Icons.tune_rounded,
                color: AppColors.textWhite,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchBottomSheet(
      BuildContext context, DoctorController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'البحث عن الأطباء',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Search Field
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو التخصص...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                // البحث المباشر
                if (value.length >= 2) {
                  controller.searchController.text = value;
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  controller.searchController.text = value;
                  Get.back();
                  // TODO: الانتقال لصفحة نتائج البحث
                }
              },
            ),

            const SizedBox(height: 16),

            // Quick Search Suggestions
            Text(
              'البحث السريع:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'أطباء الأطفال',
                'أطباء القلب',
                'أطباء الأسنان',
                'أطباء العيون',
              ]
                  .map((suggestion) => GestureDetector(
                        onTap: () {
                          controller.searchController.text = suggestion;
                          Get.back();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            suggestion,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showFilterBottomSheet(
      BuildContext context, DoctorController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: const BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'فلترة النتائج',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  child: const Text('مسح الكل'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Specialization Filter
            Text(
              'التخصص:',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: 8),

            Obx(() => DropdownButtonFormField<int>(
                  value: controller.selectedSpecializationId.value == 0
                      ? null
                      : controller.selectedSpecializationId.value,
                  decoration: InputDecoration(
                    hintText: 'اختر التخصص',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: controller.specializations.map((spec) {
                    return DropdownMenuItem<int>(
                      value: spec.id,
                      child: Text(spec.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    controller.applySpecializationFilter(value);
                  },
                )),

            const SizedBox(height: 16),

            // Apply Filter Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('تطبيق الفلتر'),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
