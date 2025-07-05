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
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize DoctorController if not already registered
    if (!Get.isRegistered<DoctorController>()) {
      Get.lazyPut<DoctorController>(() => DoctorController());
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
              // Header
              const SliverToBoxAdapter(
                child: HomeHeader(),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: SearchBarWidget(),
                ),
              ),

              // Specializations Section - Safe Widget
              const SliverToBoxAdapter(
                child: _SafeSpecializationsSection(),
              ),

              // Top Doctors Section - Safe Widget
              const SliverToBoxAdapter(
                child: _SafeTopDoctorsSection(),
              ),

              // Nearby Doctors Section - Safe Widget
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
      if (Get.isRegistered<DoctorController>()) {
        final doctorController = Get.find<DoctorController>();
        await doctorController.refreshData();
      }
      if (Get.isRegistered<GeneralController>()) {
        final generalController = Get.find<GeneralController>();
        await generalController.refreshData();
      }
    } catch (e) {
      print('Error refreshing data: $e');
    }
  }
}

// Safe wrapper for SpecializationsSection
class _SafeSpecializationsSection extends StatelessWidget {
  const _SafeSpecializationsSection();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GeneralController>(
      init: Get.isRegistered<GeneralController>() ? null : GeneralController(),
      builder: (controller) {
        if (controller.specializations.isEmpty) {
          return const _LoadingSection(title: 'التخصصات');
        }
        return SpecializationsSection();
      },
    );
  }
}

// Safe wrapper for TopDoctorsSection
class _SafeTopDoctorsSection extends StatelessWidget {
  const _SafeTopDoctorsSection();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorController>(
      init: Get.isRegistered<DoctorController>() ? null : DoctorController(),
      builder: (controller) {
        return TopDoctorsSection();
      },
    );
  }
}

// Safe wrapper for NearbyDoctorsSection
class _SafeNearbyDoctorsSection extends StatelessWidget {
  const _SafeNearbyDoctorsSection();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DoctorController>(
      init: Get.isRegistered<DoctorController>() ? null : DoctorController(),
      builder: (controller) {
        return NearbyDoctorsSection();
      },
    );
  }
}

// Loading widget for sections
class _LoadingSection extends StatelessWidget {
  final String title;

  const _LoadingSection({required this.title});

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
            child: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
