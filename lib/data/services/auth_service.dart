import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_constants.dart';
import '../models/base_response_model.dart';
import '../models/user_model.dart';

class AuthService {
  static final Dio _dio = ApiConfig.dio;

  // تسجيل مستخدم جديد
  static Future<BaseResponse<AuthResponse>> signUp(
      SignUpRequest request) async {
    try {
      final response = await _dio.post(
        AppConstants.userSignUp,
        data: request.toJson(),
      );

      final baseResponse = BaseResponse<AuthResponse>.fromJson(
        ApiConfig.handleResponse(response)!,
        (json) => AuthResponse.fromJson(json),
      );

      // حفظ بيانات المستخدم إذا نجح التسجيل
      if (baseResponse.isSuccess && baseResponse.data != null) {
        final authData = baseResponse.data!;
        ApiConfig.saveUserId(authData.userId);
        ApiConfig.saveUserName(authData.name);
        if (baseResponse.token != null) {
          ApiConfig.saveToken(baseResponse.token!);
        }
        // المستخدم الجديد = مريض بشكل افتراضي
        ApiConfig.saveUserType(AppConstants.userTypePatient);
      }

      return baseResponse;
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  // تسجيل الدخول
  static Future<BaseResponse<AuthResponse>> signIn(
      SignInRequest request) async {
    try {
      final response = await _dio.post(
        AppConstants.userSignIn,
        data: request.toJson(),
      );

      final baseResponse = BaseResponse<AuthResponse>.fromJson(
        ApiConfig.handleResponse(response)!,
        (json) => AuthResponse.fromJson(json),
      );

      // حفظ بيانات المستخدم إذا نجح تسجيل الدخول
      if (baseResponse.isSuccess && baseResponse.data != null) {
        final authData = baseResponse.data!;
        ApiConfig.saveUserId(authData.userId);
        ApiConfig.saveUserName(authData.name);
        if (baseResponse.token != null) {
          ApiConfig.saveToken(baseResponse.token!);
        }

        // التحقق من نوع المستخدم (سيتم تحديده لاحقاً)
        // TODO: إضافة API للتحقق من نوع المستخدم
        ApiConfig.saveUserType(AppConstants.userTypePatient);
      }

      return baseResponse;
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  // رفع صورة الملف الشخصي
  static Future<BaseResponse<Map<String, dynamic>>> uploadProfileImage(
    String imagePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        AppConstants.userProfileImage,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return BaseResponse<Map<String, dynamic>>.fromJson(
        ApiConfig.handleResponse(response)!,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في رفع الصورة: $e');
    }
  }

  // تسجيل الخروج
  static Future<void> logout() async {
    try {
      // مسح البيانات المحلية
      ApiConfig.clearAuthData();

      // TODO: إضافة API logout إذا أصبح متوفراً
      // await _dio.post('/User/logout');
    } catch (e) {
      // حتى لو فشل، امسح البيانات المحلية
      ApiConfig.clearAuthData();
      throw Exception('حدث خطأ في تسجيل الخروج: $e');
    }
  }

  // التحقق من حالة تسجيل الدخول
  static bool isLoggedIn() {
    final token = ApiConfig.getToken();
    final userId = ApiConfig.getUserId();
    return token != null &&
        token.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty;
  }

  // الحصول على بيانات المستخدم المحفوظة
  static UserModel? getCurrentUser() {
    final userId = ApiConfig.getUserId();
    final userName = ApiConfig.getUserName();

    if (userId == null || userName == null) return null;

    return UserModel(
      id: userId,
      name: userName,
      normalizedName: '', // سيتم جلبه من API لاحقاً
      phoneNumber: '', // سيتم جلبه من API لاحقاً
      email: '', // سيتم جلبه من API لاحقاً
    );
  }

  // التحقق من نوع المستخدم
  static String getCurrentUserType() {
    return ApiConfig.getUserType() ?? AppConstants.userTypePatient;
  }

  // التحقق من أن المستخدم طبيب
  static bool isDoctor() {
    return getCurrentUserType() == AppConstants.userTypeDoctor;
  }

  // التحقق من أن المستخدم مريض
  static bool isPatient() {
    return getCurrentUserType() == AppConstants.userTypePatient;
  }

  // تحديث نوع المستخدم (عند تسجيل عيادة مثلاً)
  static void updateUserType(String userType) {
    ApiConfig.saveUserType(userType);
  }

  // تحديث اسم المستخدم
  static void updateUserName(String userName) {
    ApiConfig.saveUserName(userName);
  }

  // TODO: إضافة هذه الدوال عندما تصبح APIs متوفرة

  // تغيير كلمة المرور
  // static Future<BaseResponse<void>> changePassword({
  //   required String currentPassword,
  //   required String newPassword,
  // }) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // إعادة تعيين كلمة المرور
  // static Future<BaseResponse<void>> resetPassword(String email) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // تحديث الملف الشخصي
  // static Future<BaseResponse<UserModel>> updateProfile(
  //   Map<String, dynamic> updates,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // جلب تفاصيل المستخدم الحالي
  // static Future<BaseResponse<UserModel>> getCurrentUserDetails() async {
  //   // سيتم تطويرها لاحقاً
  // }
}
