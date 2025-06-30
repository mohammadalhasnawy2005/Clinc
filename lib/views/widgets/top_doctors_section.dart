import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../controllers/doctor_controller.dart';
import '../../../data/models/doctor_model.dart';
import 'doctor_card.dart';

class TopDoctorsSection extends StatelessWidget {
  const TopDoctorsSection({super.key});

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
                AppStrings.topDoctors,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: الانتقال لصفحة جميع الأطباء
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

          // Top Doctors List
          FutureBuilder<List<DoctorModel>>(
            future: doctorController.getTopDoctors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingDoctors();
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const _EmptyDoctors();
              }

              final topDoctors = snapshot.data!.take(5).toList();

              return SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: topDoctors.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == 0 ? 0 : 12,
                        left: index == topDoctors.length - 1 ? 0 : 12,
                      ),
                      child: DoctorCard(
                        doctor: topDoctors[index],
                        onTap: () {
                          doctorController.selectDoctor(topDoctors[index]);
                          Get.toNamed('/doctor-profile');
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LoadingDoctors extends StatelessWidget {
  const _LoadingDoctors();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyDoctors extends StatelessWidget {
  const _EmptyDoctors();

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
          'لا توجد أطباء متاحون حالياً',
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
