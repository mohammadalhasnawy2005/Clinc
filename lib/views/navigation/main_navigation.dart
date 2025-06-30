import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/general_controller.dart';
import '../home/home_screen.dart';
import '../appointment/my_appointments_screen.dart';
import '../profile/profile_screen.dart';
import '../widgets/chat_floating_button.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final GeneralController generalController = Get.find<GeneralController>();

    return Obx(() {
      // تحديد الصفحات حسب نوع المستخدم
      final List<NavigationItem> items = _getNavigationItems(authController);

      return Scaffold(
        body: Stack(
          children: [
            // الصفحة الحالية
            IndexedStack(
              index: generalController.currentBottomNavIndex.value,
              children: items.map((item) => item.page).toList(),
            ),

            // زر المحادثة العائم
            const ChatFloatingButton(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: generalController.currentBottomNavIndex.value,
          onTap: generalController.changeBottomNavIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.backgroundLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          elevation: 8,
          items: items
              .map((item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    activeIcon: Icon(item.activeIcon ?? item.icon),
                    label: item.label,
                  ))
              .toList(),
        ),
      );
    });
  }

  List<NavigationItem> _getNavigationItems(AuthController authController) {
    final List<NavigationItem> baseItems = [
      NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: AppStrings.home,
        page: const HomeScreen(),
      ),
    ];

    if (authController.isLoggedIn) {
      if (authController.isPatient) {
        // صفحات المريض
        baseItems.addAll([
          NavigationItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today_rounded,
            label: AppStrings.appointments,
            page: const MyAppointmentsScreen(),
          ),
          NavigationItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: AppStrings.profile,
            page: const ProfileScreen(),
          ),
        ]);
      } else if (authController.isDoctor) {
        // صفحات الطبيب
        baseItems.addAll([
          // NavigationItem(
          //   icon: Icons.dashboard_outlined,
          //   activeIcon: Icons.dashboard_rounded,
          //   label: AppStrings.doctorDashboard,
          //   page: const DoctorDashboardScreen(),
          // ),
          NavigationItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today_rounded,
            label: AppStrings.appointments,
            page: const MyAppointmentsScreen(),
          ),
          NavigationItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: AppStrings.profile,
            page: const ProfileScreen(),
          ),
        ]);
      }
    } else {
      // للمستخدم غير المسجل - صفحات محدودة
      baseItems.addAll([
        NavigationItem(
          icon: Icons.search_outlined,
          activeIcon: Icons.search_rounded,
          label: 'البحث',
          page: const _SearchScreen(),
        ),
        NavigationItem(
          icon: Icons.login_outlined,
          activeIcon: Icons.login_rounded,
          label: 'تسجيل الدخول',
          page: const _LoginPromptScreen(),
        ),
      ]);
    }

    return baseItems;
  }
}

class NavigationItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Widget page;

  NavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.page,
  });
}

// صفحة البحث للمستخدم غير المسجل
class _SearchScreen extends StatelessWidget {
  const _SearchScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن الأطباء'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              size: 80,
              color: AppColors.gray400,
            ),
            SizedBox(height: 16),
            Text(
              'البحث عن الأطباء',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ابحث عن الأطباء حسب التخصص أو الاسم',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            // TODO: إضافة وظائف البحث هنا
          ],
        ),
      ),
    );
  }
}

// صفحة دعوة تسجيل الدخول
class _LoginPromptScreen extends StatelessWidget {
  const _LoginPromptScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'سجل دخولك للوصول لحسابك',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'احجز مواعيدك وتابع حالتك الصحية',
                style: TextStyle(
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.toNamed('/signup'),
                  child: const Text('إنشاء حساب جديد'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
