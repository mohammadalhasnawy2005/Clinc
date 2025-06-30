import 'package:clinic/views/widgets/home_header.dart';
import 'package:clinic/views/widgets/nearby_doctors_section.dart';
import 'package:clinic/views/widgets/search_bar_widget.dart';
import 'package:clinic/views/widgets/specializations_section.dart';
import 'package:clinic/views/widgets/top_doctors_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/doctor_controller.dart';
import '../../controllers/general_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final AuthController authController = Get.find<AuthController>();
    final DoctorController doctorController = Get.put(DoctorController());
    final GeneralController generalController = Get.find<GeneralController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              doctorController.refreshData(),
              generalController.refreshData(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: HomeHeader(),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: SearchBarWidget(),
                ),
              ),

              // Specializations Section
              SliverToBoxAdapter(
                child: SpecializationsSection(),
              ),

              // Top Doctors Section
              SliverToBoxAdapter(
                child: TopDoctorsSection(),
              ),

              // Nearby Doctors Section
              SliverToBoxAdapter(
                child: NearbyDoctorsSection(),
              ),

              // Bottom Padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100), // للـ Bottom Navigation
              ),
            ],
          ),
        ),
      ),
    );
  }
}
