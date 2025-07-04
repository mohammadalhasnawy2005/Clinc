import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/doctor_controller.dart';
import '../../controllers/general_controller.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/specializations_section.dart';
import '../widgets/top_doctors_section.dart';
import '../widgets/nearby_doctors_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DoctorController doctorController;
  late AuthController authController;
  late GeneralController generalController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    try {
      // التأكد من وجود Controllers الأساسية
      if (!Get.isRegistered<AuthController>()) {
        Get.put(AuthController(), permanent: true);
      }
      authController = Get.find<AuthController>();

      if (!Get.isRegistered<GeneralController>()) {
        Get.put(GeneralController(), permanent: true);
      }
      generalController = Get.find<GeneralController>();

      // إنشاء DoctorController للصفحة الرئيسية فقط
      if (!Get.isRegistered<DoctorController>()) {
        doctorController = Get.put(DoctorController(), tag: 'home');
      } else {
        doctorController = Get.find<DoctorController>();
      }

      print('✅ All controllers initialized successfully');
    } catch (e) {
      print('❌ Error initializing controllers: $e');
      // إنشاء controllers افتراضية في حالة الخطأ
      authController = Get.put(AuthController(), permanent: true);
      generalController = Get.put(GeneralController(), permanent: true);
      doctorController = Get.put(DoctorController(), tag: 'home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              // Header - بدون Obx
              const SliverToBoxAdapter(
                child: _SafeHomeHeader(),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: _SafeSearchBar(),
                ),
              ),

              // Specializations Section
              const SliverToBoxAdapter(
                child: _SafeSpecializationsSection(),
              ),

              // Top Doctors Section
              const SliverToBoxAdapter(
                child: _SafeTopDoctorsSection(),
              ),

              // Nearby Doctors Section
              const SliverToBoxAdapter(
                child: _SafeNearbyDoctorsSection(),
              ),

              // Bottom Padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    try {
      await Future.wait([
        if (Get.isRegistered<DoctorController>())
          doctorController.refreshData(),
        if (Get.isRegistered<GeneralController>())
          generalController.refreshData(),
      ]);
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }

  @override
  void dispose() {
    // تنظيف DoctorController الخاص بالصفحة الرئيسية
    if (Get.isRegistered<DoctorController>(tag: 'home')) {
      Get.delete<DoctorController>(tag: 'home');
    }
    super.dispose();
  }
}

// Widget آمن للـ Header
class _SafeHomeHeader extends StatelessWidget {
  const _SafeHomeHeader();

  @override
  Widget build(BuildContext context) {
    try {
      if (Get.isRegistered<AuthController>()) {
        return GetBuilder<AuthController>(
          builder: (controller) => HomeHeader(),
        );
      }
    } catch (e) {
      print('Error in HomeHeader: $e');
    }

    // Fallback header بدون GetX
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً بك في Medics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ابحث عن أفضل الأطباء',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget آمن للـ Search Bar
class _SafeSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    try {
      if (Get.isRegistered<DoctorController>()) {
        return SearchBarWidget();
      }
    } catch (e) {
      print('Error in SearchBar: $e');
    }

    // Fallback search bar
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ابحث عن الأطباء...',
                style: TextStyle(
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
          Icon(
            Icons.search,
            color: AppColors.textLight,
          ),
          SizedBox(width: 16),
        ],
      ),
    );
  }
}

// Widget آمن للتخصصات
class _SafeSpecializationsSection extends StatelessWidget {
  const _SafeSpecializationsSection();

  @override
  Widget build(BuildContext context) {
    try {
      if (Get.isRegistered<GeneralController>()) {
        return SpecializationsSection();
      }
    } catch (e) {
      print('Error in SpecializationsSection: $e');
    }

    return const _FallbackSection(
      title: 'التخصصات',
      message: 'جاري تحميل التخصصات...',
    );
  }
}

// Widget آمن لأفضل الأطباء
class _SafeTopDoctorsSection extends StatelessWidget {
  const _SafeTopDoctorsSection();

  @override
  Widget build(BuildContext context) {
    try {
      if (Get.isRegistered<DoctorController>()) {
        return TopDoctorsSection();
      }
    } catch (e) {
      print('Error in TopDoctorsSection: $e');
    }

    return const _FallbackSection(
      title: 'أفضل الأطباء',
      message: 'جاري تحميل الأطباء...',
    );
  }
}

// Widget آمن للأطباء القريبين
class _SafeNearbyDoctorsSection extends StatelessWidget {
  const _SafeNearbyDoctorsSection();

  @override
  Widget build(BuildContext context) {
    try {
      if (Get.isRegistered<DoctorController>()) {
        return NearbyDoctorsSection();
      }
    } catch (e) {
      print('Error in NearbyDoctorsSection: $e');
    }

    return const _FallbackSection(
      title: 'الأطباء القريبون',
      message: 'جاري تحميل الأطباء القريبين...',
    );
  }
}

// Widget احتياطي
class _FallbackSection extends StatelessWidget {
  final String title;
  final String message;

  const _FallbackSection({
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
