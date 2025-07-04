import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../data/services/auth_service.dart';
import '../data/models/user_model.dart';
import '../core/utils/app_utils.dart';
import '../core/constants/app_constants.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  // Loading States
  final RxBool isLoading = false.obs;
  final RxBool isSignUpLoading = false.obs;
  final RxBool isSignInLoading = false.obs;
  final RxBool isUploadingImage = false.obs;

  // User Data
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString userType = AppConstants.userTypePatient.obs;

  // Form Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Form Keys
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  // Profile Image
  final RxString profileImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void _initializeUser() {
    try {
      final user = AuthService.getCurrentUser();
      if (user != null) {
        currentUser.value = user;
        userType.value = AuthService.getCurrentUserType();
      }
    } catch (e) {
      print('Error initializing user: $e');
    }
  }

  Future<void> signUp() async {
    if (!signUpFormKey.currentState!.validate()) return;

    try {
      isSignUpLoading.value = true;

      final request = SignUpRequest(
        name: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        password: passwordController.text.trim(),
        email: emailController.text.trim(),
      );

      final response = await AuthService.signUp(request);

      if (response.isSuccess && response.data != null) {
        currentUser.value = UserModel(
          id: response.data!.userId,
          name: response.data!.name,
          normalizedName: '',
          phoneNumber: response.data!.phoneNumber,
          email: response.data!.email,
        );

        userType.value = AppConstants.userTypePatient;

        AppUtils.showSuccessSnackbar('نجح التسجيل', 'تم إنشاء حسابك بنجاح');

        if (profileImagePath.value.isNotEmpty) {
          await uploadProfileImage();
        }

        _clearForm();
        Get.offAllNamed('/main-navigation');
      } else {
        AppUtils.showErrorSnackbar('فشل التسجيل', response.message);
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في التسجيل', e.toString());
    } finally {
      isSignUpLoading.value = false;
    }
  }

  Future<void> signIn() async {
    if (!signInFormKey.currentState!.validate()) return;

    try {
      isSignInLoading.value = true;

      final request = SignInRequest(
        phoneNumber: phoneController.text.trim(),
        password: passwordController.text.trim(),
      );

      final response = await AuthService.signIn(request);

      if (response.isSuccess && response.data != null) {
        currentUser.value = UserModel(
          id: response.data!.userId,
          name: response.data!.name,
          normalizedName: '',
          phoneNumber: response.data!.phoneNumber,
          email: response.data!.email,
        );

        userType.value = AuthService.getCurrentUserType();

        AppUtils.showSuccessSnackbar('مرحباً بعودتك', 'تم تسجيل الدخول بنجاح');

        _clearForm();
        Get.offAllNamed('/main-navigation');
      } else {
        AppUtils.showErrorSnackbar('فشل تسجيل الدخول', response.message);
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في تسجيل الدخول', e.toString());
    } finally {
      isSignInLoading.value = false;
    }
  }

  Future<void> uploadProfileImage() async {
    if (profileImagePath.value.isEmpty) return;

    try {
      isUploadingImage.value = true;

      final response =
          await AuthService.uploadProfileImage(profileImagePath.value);

      if (response.isSuccess) {
        AppUtils.showSuccessSnackbar(
            'تم رفع الصورة', 'تم تحديث صورتك الشخصية بنجاح');
      } else {
        AppUtils.showErrorSnackbar('فشل رفع الصورة', response.message);
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في رفع الصورة', e.toString());
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.profileImageMaxWidth,
        maxHeight: AppConstants.profileImageMaxHeight,
        imageQuality: AppConstants.profileImageQuality,
      );

      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في اختيار الصورة', e.toString());
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.profileImageMaxWidth,
        maxHeight: AppConstants.profileImageMaxHeight,
        imageQuality: AppConstants.profileImageQuality,
      );

      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في التقاط الصورة', e.toString());
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      await AuthService.logout();

      currentUser.value = null;
      userType.value = AppConstants.userTypePatient;
      _clearForm();

      AppUtils.showSuccessSnackbar(
          'تم تسجيل الخروج', 'شكراً لاستخدام تطبيق Medics');

      Get.offAllNamed('/main-navigation');
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في تسجيل الخروج', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  bool get isLoggedIn => AuthService.isLoggedIn();
  bool get isDoctor => AuthService.isDoctor();
  bool get isPatient => AuthService.isPatient();

  void updateUserType(String newUserType) {
    userType.value = newUserType;
    AuthService.updateUserType(newUserType);
  }

  void updateUserName(String newName) {
    if (currentUser.value != null) {
      currentUser.value = currentUser.value!.copyWith(name: newName);
      AuthService.updateUserName(newName);
    }
  }

  void updateUserData({
    String? name,
    String? email,
    String? phoneNumber,
    int? age,
    String? gender,
  }) {
    if (currentUser.value != null) {
      currentUser.value = currentUser.value!.copyWith(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
        age: age,
        gender: gender,
      );
    }
  }

  void _clearForm() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    profileImagePath.value = '';
  }

  String? validateName(String? value) => AppUtils.validateName(value);
  String? validatePhone(String? value) => AppUtils.validatePhone(value);
  String? validateEmail(String? value) => AppUtils.validateEmail(value);
  String? validatePassword(String? value) => AppUtils.validatePassword(value);

  String? validateConfirmPassword(String? value) {
    return AppUtils.validateConfirmPassword(value, passwordController.text);
  }

  void showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر مصدر الصورة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('من المعرض'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('من الكاميرا'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            if (profileImagePath.value.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'إزالة الصورة',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Get.back();
                  profileImagePath.value = '';
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> refreshUserData() async {
    try {
      // TODO: إضافة API لجلب بيانات المستخدم المحدثة
    } catch (e) {
      AppUtils.logError('خطأ في تحديث بيانات المستخدم', e);
    }
  }
}
