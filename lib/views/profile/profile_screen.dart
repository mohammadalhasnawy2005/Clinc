import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/general_controller.dart';
// import 'widgets/profile_header.dart';
// import 'widgets/profile_menu_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final GeneralController generalController = Get.find<GeneralController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Settings Action
          IconButton(
            onPressed: () {
              _showSettingsBottomSheet(context, generalController);
            },
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (!authController.isLoggedIn) {
          return const _NotLoggedInView();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // Profile Header
              // ProfileHeader(),

              const SizedBox(height: 24),

              // Menu Sections
              // ProfileMenuSection(),

              const SizedBox(height: 100), // للـ Bottom Navigation
            ],
          ),
        );
      }),
    );
  }

  void _showSettingsBottomSheet(
    BuildContext context,
    GeneralController controller,
  ) {
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
              'الإعدادات',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Settings Options
            _buildSettingItem(
              context,
              icon: Icons.info_outline_rounded,
              title: 'حول التطبيق',
              onTap: controller.showAboutApp,
            ),

            _buildSettingItem(
              context,
              icon: Icons.update_rounded,
              title: 'البحث عن تحديثات',
              onTap: controller.checkForUpdates,
            ),

            _buildSettingItem(
              context,
              icon: Icons.storage_rounded,
              title: 'مسح الذاكرة المؤقتة',
              onTap: controller.clearCache,
            ),

            _buildSettingItem(
              context,
              icon: Icons.bar_chart_rounded,
              title: 'إحصائيات التطبيق',
              onTap: controller.showGeneralStats,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _NotLoggedInView extends StatelessWidget {
  const _NotLoggedInView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 100,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 24),
            Text(
              'سجل دخولك لعرض ملفك الشخصي',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'احصل على تجربة شخصية ومتابعة مواعيدك',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.toNamed('/login'),
                child: const Text('تسجيل الدخول'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
