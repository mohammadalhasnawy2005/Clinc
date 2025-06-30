import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../controllers/general_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GeneralController controller = Get.find<GeneralController>();
    final PageController pageController = PageController();

    final List<OnboardingPage> pages = [
      OnboardingPage(
        title: AppStrings.onboardingTitle1,
        description: AppStrings.onboardingDesc1,
        icon: Icons.medical_services_rounded,
        color: AppColors.primary,
      ),
      OnboardingPage(
        title: AppStrings.onboardingTitle2,
        description: AppStrings.onboardingDesc2,
        icon: Icons.search_rounded,
        color: AppColors.primaryLight,
      ),
      OnboardingPage(
        title: AppStrings.onboardingTitle3,
        description: AppStrings.onboardingDesc3,
        icon: Icons.video_call_rounded,
        color: AppColors.primaryDark,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60), // للتوازن
                  Obx(() => Text(
                        '${controller.currentOnboardingPage.value + 1} / ${pages.length}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      )),
                  TextButton(
                    onPressed: controller.skipOnboarding,
                    child: Text(
                      AppStrings.skip,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: controller.setOnboardingPage,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(page: pages[index]);
                },
              ),
            ),

            // Bottom Section
            Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  // Page Indicators
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => _buildPageIndicator(
                            context,
                            index,
                            controller.currentOnboardingPage.value,
                          ),
                        ),
                      )),

                  const SizedBox(height: 30),

                  // Navigation Buttons
                  Obx(() {
                    final isLastPage = controller.currentOnboardingPage.value ==
                        pages.length - 1;

                    return Row(
                      children: [
                        // Previous Button
                        if (controller.currentOnboardingPage.value > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                              child: const Text('السابق'),
                            ),
                          ),

                        if (controller.currentOnboardingPage.value > 0)
                          const SizedBox(width: 16),

                        // Next/Get Started Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (isLastPage) {
                                controller.skipOnboarding();
                              } else {
                                pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              }
                            },
                            child: Text(
                              isLastPage
                                  ? AppStrings.getStarted
                                  : AppStrings.next,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(
      BuildContext context, int index, int currentIndex) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: index == currentIndex ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: index == currentIndex ? AppColors.primary : AppColors.gray300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPage page;

  const OnboardingPageWidget({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 70,
              color: page.color,
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
