import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Header
              _buildHeader(context),

              const SizedBox(height: 40),

              // Login Form
              _buildLoginForm(controller),

              const SizedBox(height: 24),

              // Login Button
              Obx(() => CustomButton(
                    text: AppStrings.login,
                    onPressed: controller.signIn,
                    isLoading: controller.isSignInLoading.value,
                  )),

              const SizedBox(height: 16),

              // Forgot Password
              TextButton(
                onPressed: () {
                  // TODO: تطوير نسيان كلمة المرور لاحقاً
                  Get.snackbar(
                    'قريباً',
                    'ميزة نسيان كلمة المرور ستكون متاحة قريباً',
                  );
                },
                child: Text(
                  AppStrings.forgotPassword,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // OR Divider
              _buildOrDivider(context),

              const SizedBox(height: 20),

              // Social Login Buttons
              _buildSocialLoginButtons(),

              const SizedBox(height: 30),

              // Sign Up Link
              _buildSignUpLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // App Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.medical_services_rounded,
            size: 40,
            color: AppColors.textWhite,
          ),
        ),

        const SizedBox(height: 24),

        // Welcome Text
        Text(
          AppStrings.welcomeBack,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 8),

        Text(
          'سجل دخولك للوصول لحسابك',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(AuthController controller) {
    return Form(
      key: controller.signInFormKey,
      child: Column(
        children: [
          // Phone Number Field
          CustomTextField(
            controller: controller.phoneController,
            labelText: AppStrings.phoneNumber,
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: controller.validatePhone,
          ),

          const SizedBox(height: 16),

          // Password Field
          CustomTextField(
            controller: controller.passwordController,
            labelText: AppStrings.password,
            prefixIcon: Icons.lock_rounded,
            isPassword: true,
            validator: controller.validatePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildOrDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.border,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.signInWith,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.border,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        // Google Login
        OutlinedButton.icon(
          onPressed: () {
            // TODO: تطوير تسجيل الدخول بـ Google لاحقاً
            Get.snackbar(
              'قريباً',
              'تسجيل الدخول بـ Google سيكون متاحاً قريباً',
            );
          },
          icon: const Icon(Icons.g_mobiledata, color: Colors.red),
          label: Text('تسجيل الدخول بـ ${AppStrings.google}'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: AppColors.border),
          ),
        ),

        const SizedBox(height: 12),

        // Apple Login (iOS only)
        if (GetPlatform.isIOS)
          OutlinedButton.icon(
            onPressed: () {
              // TODO: تطوير تسجيل الدخول بـ Apple لاحقاً
              Get.snackbar(
                'قريباً',
                'تسجيل الدخول بـ Apple سيكون متاحاً قريباً',
              );
            },
            icon: const Icon(Icons.apple, color: Colors.black),
            label: Text('تسجيل الدخول بـ ${AppStrings.apple}'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: AppColors.border),
            ),
          ),
      ],
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.dontHaveAccount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        TextButton(
          onPressed: () => Get.offNamed('/signup'),
          child: Text(
            AppStrings.signUp,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
