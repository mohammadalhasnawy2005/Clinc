import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../controllers/doctor_controller.dart';
import '../../../data/models/doctor_model.dart';
import 'nearby_doctor_item.dart';

class NearbyDoctorsSection extends StatelessWidget {
  const NearbyDoctorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final DoctorController doctorController = Get.find<DoctorController>();

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.nearbyDoctors,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: الانتقال لصفحة الأطباء القريبين
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

          // Nearby Doctors List
          FutureBuilder<List<DoctorModel>>(
            future: doctorController.getNearbyDoctors(1), // بغداد كمثال
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingNearbyDoctors();
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const _EmptyNearbyDoctors();
              }

              final nearbyDoctors = snapshot.data!.take(3).toList();

              return Column(
                children: nearbyDoctors.map((doctor) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NearbyDoctorItem(
                      doctor: doctor,
                      onTap: () {
                        doctorController.selectDoctor(doctor);
                        Get.toNamed('/doctor-profile');
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LoadingNearbyDoctors extends StatelessWidget {
  const _LoadingNearbyDoctors();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}

class _EmptyNearbyDoctors extends StatelessWidget {
  const _EmptyNearbyDoctors();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          'لا توجد أطباء قريبون في منطقتك',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
