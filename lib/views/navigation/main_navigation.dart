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

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late GeneralController generalController;
  late AuthController authController;

  int currentIndex = 0;
  List<NavigationItem> navigationItems = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupNavigationItems();
  }

  void _initializeControllers() {
    try {
      // التأكد من وجود Controllers
      if (!Get.isRegistered<AuthController>()) {
        Get.put(AuthController(), permanent: true);
      }
      authController = Get.find<AuthController>();

      if (!Get.isRegistered<GeneralController>()) {
        Get.put(GeneralController(), permanent: true);
      }
      generalController = Get.find<GeneralController>();

      print('✅ MainNavigation controllers initialized');
    } catch (e) {
      print('❌ Error initializing controllers in MainNavigation: $e');
      // إنشاء controllers افتراضية
      authController = Get.put(AuthController(), permanent: true);
      generalController = Get.put(GeneralController(), permanent: true);
    }
  }

  void _setupNavigationItems() {
    navigationItems = _getNavigationItems();
  }

  List<NavigationItem> _getNavigationItems() {
    final List<NavigationItem> baseItems = [
      NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: AppStrings.home,
        page: const HomeScreen(),
      ),
    ];

    try {
      if (authController.isLoggedIn) {
        if (authController.isPatient) {
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
        }
      } else {
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
    } catch (e) {
      print('Error getting navigation items: $e');
      // إرجاع العناصر الأساسية فقط في حالة الخطأ
    }

    return baseItems;
  }

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });

    // تحديث controller إذا كان موجود
    try {
      if (Get.isRegistered<GeneralController>()) {
        generalController.changeBottomNavIndex(index);
      }
    } catch (e) {
      print('Error updating controller index: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // التأكد من وجود العناصر
    if (navigationItems.isEmpty) {
      _setupNavigationItems();
    }

    // التأكد من أن currentIndex صالح
    if (currentIndex >= navigationItems.length) {
      currentIndex = 0;
    }

    return Scaffold(
      body: Stack(
        children: [
          // عرض الصفحة الحالية
          IndexedStack(
            index: currentIndex,
            children: navigationItems
                .map((item) => _SafePageWrapper(
                      child: item.page,
                    ))
                .toList(),
          ),

          // زر المحادثة العائم
          const ChatFloatingButton(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        elevation: 8,
        items: navigationItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon: Icon(item.activeIcon ?? item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

// Wrapper آمن للصفحات
class _SafePageWrapper extends StatelessWidget {
  final Widget child;

  const _SafePageWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          print('Error loading page: $e');
          return _ErrorPageWidget(error: e.toString());
        }
      },
    );
  }
}

// صفحة الخطأ
class _ErrorPageWidget extends StatelessWidget {
  final String error;

  const _ErrorPageWidget({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'حدث خطأ في تحميل الصفحة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // إعادة تشغيل التطبيق
                  Get.offAllNamed('/splash');
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
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

// صفحة البحث
class _SearchScreen extends StatelessWidget {
  const _SearchScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن الأطباء'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        backgroundColor: Colors.transparent,
        elevation: 0,
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
