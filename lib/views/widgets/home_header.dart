import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../controllers/auth_controller.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Greeting & User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textWhite.withOpacity(0.9),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      return Text(
                        authController.isLoggedIn
                            ? 'مرحباً ${authController.currentUser.value?.name ?? ''}'
                            : 'مرحباً بك في ${AppStrings.appName}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                      );
                    }),
                  ],
                ),
              ),

              // Profile/Login Button
              GestureDetector(
                onTap: () {
                  if (authController.isLoggedIn) {
                    Get.toNamed('/profile');
                  } else {
                    Get.toNamed('/login');
                  }
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.textWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppColors.textWhite.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Obx(() {
                    return Icon(
                      authController.isLoggedIn
                          ? Icons.person_rounded
                          : Icons.login_rounded,
                      color: AppColors.textWhite,
                      size: 24,
                    );
                  }),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick Actions (if logged in)
          Obx(() {
            if (!authController.isLoggedIn) return const SizedBox.shrink();

            return Row(
              children: [
                if (authController.isPatient) ...[
                  _buildQuickAction(
                    context,
                    icon: Icons.calendar_today_rounded,
                    label: 'مواعيدي',
                    onTap: () => Get.toNamed('/my-appointments'),
                  ),
                  const SizedBox(width: 12),
                ],
                if (authController.isDoctor) ...[
                  _buildQuickAction(
                    context,
                    icon: Icons.dashboard_rounded,
                    label: 'لوحة التحكم',
                    onTap: () => Get.toNamed('/doctor-dashboard'),
                  ),
                  const SizedBox(width: 12),
                ],
                _buildQuickAction(
                  context,
                  icon: Icons.location_on_rounded,
                  label: 'أقرب الأطباء',
                  onTap: () {
                    // TODO: فتح خريطة أو قائمة الأطباء القريبين
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.textWhite.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.textWhite.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.textWhite,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'صباح الخير';
    } else if (hour >= 12 && hour < 17) {
      return 'مساء الخير';
    } else if (hour >= 17 && hour < 21) {
      return 'مساء الخير';
    } else {
      return 'ليلة سعيدة';
    }
  }
}
