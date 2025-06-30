import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.signUp),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context),

              const SizedBox(height: 30),

              // Profile Image Picker
              _buildProfileImagePicker(controller),

              const SizedBox(height: 24),

              // Sign Up Form
              _buildSignUpForm(controller),

              const SizedBox(height: 24),

              // Sign Up Button
              Obx(() => CustomButton(
                    text: AppStrings.signUp,
                    onPressed: controller.signUp,
                    isLoading: controller.isSignUpLoading.value,
                  )),

              const SizedBox(height: 20),

              // OR Divider
              _buildOrDivider(context),

              const SizedBox(height: 20),

              // Social Sign Up Buttons
              _buildSocialSignUpButtons(),

              const SizedBox(height: 30),

              // Login Link
              _buildLoginLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'إنشاء حساب جديد',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'املأ المعلومات أدناه للبدء',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildProfileImagePicker(AuthController controller) {
    return Center(
      child: GestureDetector(
        onTap: controller.showImagePickerOptions,
        child: Obx(() {
          return Stack(
            children: [
              // Profile Image Circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gray200,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                ),
                child: controller.profileImagePath.value.isNotEmpty
                    ? ClipOval(
                        child: Image.file(
                          File(controller.profileImagePath.value),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: AppColors.textLight,
                      ),
              ),

              // Add Photo Button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.backgroundLight,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSignUpForm(AuthController controller) {
    return Form(
      key: controller.signUpFormKey,
      child: Column(
        children: [
          // Full Name Field
          CustomTextField(
            controller: controller.nameController,
            labelText: AppStrings.fullName,
            prefixIcon: Icons.person_rounded,
            keyboardType: TextInputType.name,
            validator: controller.validateName,
          ),

          const SizedBox(height: 16),

          // Phone Number Field
          CustomTextField(
            controller: controller.phoneController,
            labelText: AppStrings.phoneNumber,
            prefixIcon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: controller.validatePhone,
          ),

          const SizedBox(height: 16),

          // Email Field
          CustomTextField(
            controller: controller.emailController,
            labelText: AppStrings.email,
            prefixIcon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
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

          const SizedBox(height: 16),

          // Confirm Password Field
          CustomTextField(
            controller: controller.confirmPasswordController,
            labelText: AppStrings.confirmPassword,
            prefixIcon: Icons.lock_rounded,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: controller.validateConfirmPassword,
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
            AppStrings.signUpWith,
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

  Widget _buildSocialSignUpButtons() {
    return Column(
      children: [
        // Google Sign Up
        OutlinedButton.icon(
          onPressed: () {
            // TODO: تطوير تسجيل الدخول بـ Google لاحقاً
            Get.snackbar(
              'قريباً',
              'التسجيل بـ Google سيكون متاحاً قريباً',
            );
          },
          icon: const Icon(Icons.g_mobiledata, color: Colors.red),
          label: Text('التسجيل بـ ${AppStrings.google}'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: AppColors.border),
          ),
        ),

        const SizedBox(height: 12),

        // Apple Sign Up (iOS only)
        if (GetPlatform.isIOS)
          OutlinedButton.icon(
            onPressed: () {
              // TODO: تطوير تسجيل الدخول بـ Apple لاحقاً
              Get.snackbar(
                'قريباً',
                'التسجيل بـ Apple سيكون متاحاً قريباً',
              );
            },
            icon: const Icon(Icons.apple, color: Colors.black),
            label: Text('التسجيل بـ ${AppStrings.apple}'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: AppColors.border),
            ),
          ),
      ],
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppStrings.alreadyHaveAccount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        TextButton(
          onPressed: () => Get.offNamed('/login'),
          child: Text(
            AppStrings.login,
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
