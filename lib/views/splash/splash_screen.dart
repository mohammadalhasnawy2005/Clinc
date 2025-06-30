import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/general_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final AuthController _authController = Get.find<AuthController>();
  final GeneralController _generalController = Get.find<GeneralController>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    // انتظار مدة أقل من مدة الأنيميشن
    await Future.delayed(const Duration(
      seconds: AppConstants.splashDuration,
    ));

    await _checkAppState();
  }

  Future<void> _checkAppState() async {
    try {
      // التحقق من حالة التطبيق
      if (_generalController.isFirstTime.value) {
        // المرة الأولى - انتقال للـ Onboarding
        Get.offAllNamed('/onboarding');
      } else if (_authController.isLoggedIn) {
        // مسجل دخول - انتقال للصفحة الرئيسية
        Get.offAllNamed('/main-navigation');
      } else {
        // غير مسجل - انتقال للصفحة الرئيسية بدون تسجيل
        Get.offAllNamed('/main-navigation');
      }
    } catch (e) {
      // في حالة وجود خطأ، انتقال للصفحة الرئيسية
      Get.offAllNamed('/main-navigation');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.textWhite,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // App Name
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),

                  const SizedBox(height: 8),

                  // App Slogan
                  Text(
                    AppStrings.appSlogan,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textWhite.withOpacity(0.9),
                          fontSize: 16,
                        ),
                  ),

                  const SizedBox(height: 50),

                  // Loading Indicator
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textWhite.withOpacity(0.8),
                      ),
                      strokeWidth: 3,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Loading Text
                  Text(
                    AppStrings.loading,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textWhite.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
