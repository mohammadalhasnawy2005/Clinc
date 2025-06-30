import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

class ApiConfig {
  static late Dio _dio;
  static final GetStorage _storage = GetStorage();

  static void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout:
          const Duration(seconds: AppConstants.requestTimeoutDuration),
      receiveTimeout:
          const Duration(seconds: AppConstants.requestTimeoutDuration),
      sendTimeout: const Duration(seconds: AppConstants.requestTimeoutDuration),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Request Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // إضافة Token للطلبات التي تحتاجه
          if (_needsAuth(options.path)) {
            final token = getToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          // Log الطلب
          print('🔵 ${options.method} ${options.path}');
          if (options.data != null) {
            print('📤 Data: ${options.data}');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          // Log الاستجابة
          print('🟢 ${response.statusCode} ${response.requestOptions.path}');

          // استخراج وحفظ Token الجديد إذا وُجد
          if (response.data is Map<String, dynamic>) {
            final responseData = response.data as Map<String, dynamic>;
            if (responseData.containsKey('token') &&
                responseData['token'] != null) {
              final newToken = responseData['token'] as String;
              saveToken(newToken);
              print('🔑 Token updated');
            }
          }

          handler.next(response);
        },
        onError: (error, handler) {
          // Log الخطأ
          print(
              '🔴 Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          print('📤 Error Data: ${error.response?.data}');

          // معالجة الأخطاء الشائعة
          if (error.response?.statusCode == 401) {
            // Unauthorized - مسح Token وإعادة التوجيه للتسجيل
            clearAuthData();
            Get.offAllNamed('/login');
          }

          handler.next(error);
        },
      ),
    );
  }

  static Dio get dio => _dio;

  // Token Management
  static String? getToken() {
    return _storage.read<String>(AppConstants.userTokenKey);
  }

  static void saveToken(String token) {
    _storage.write(AppConstants.userTokenKey, token);
  }

  static void clearToken() {
    _storage.remove(AppConstants.userTokenKey);
  }

  // User Data Management
  static String? getUserId() {
    return _storage.read<String>(AppConstants.userIdKey);
  }

  static void saveUserId(String userId) {
    _storage.write(AppConstants.userIdKey, userId);
  }

  static String? getUserName() {
    return _storage.read<String>(AppConstants.userNameKey);
  }

  static void saveUserName(String userName) {
    _storage.write(AppConstants.userNameKey, userName);
  }

  static String? getUserType() {
    return _storage.read<String>(AppConstants.userTypeKey);
  }

  static void saveUserType(String userType) {
    _storage.write(AppConstants.userTypeKey, userType);
  }

  static bool isFirstTime() {
    return _storage.read<bool>(AppConstants.isFirstTimeKey) ?? true;
  }

  static void setFirstTime(bool isFirstTime) {
    _storage.write(AppConstants.isFirstTimeKey, isFirstTime);
  }

  static void clearAuthData() {
    _storage.remove(AppConstants.userTokenKey);
    _storage.remove(AppConstants.userIdKey);
    _storage.remove(AppConstants.userNameKey);
    _storage.remove(AppConstants.userTypeKey);
  }

  // Image URL Builder
  static String getImageUrl(String imageName) {
    if (imageName.isEmpty) return '';
    return '${AppConstants.imagesBaseUrl}/$imageName';
  }

  // Helper Method لتحديد الطلبات التي تحتاج Authentication
  static bool _needsAuth(String path) {
    // قائمة الطلبات التي لا تحتاج Token
    const noAuthPaths = [
      AppConstants.userSignUp,
      AppConstants.userSignIn,
      AppConstants.specializations,
      AppConstants.days,
      AppConstants.subscriptionPackages,
      AppConstants.features,
    ];

    return !noAuthPaths.any((noAuthPath) => path.contains(noAuthPath));
  }

  // Response Handler
  static Map<String, dynamic>? handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // التحقق من حالة الاستجابة
        if (responseData['status'] == 'Success') {
          return responseData;
        } else {
          // خطأ من الخادم
          final errorMessage =
              responseData['message'] ?? AppConstants.unknownErrorMessage;
          throw Exception(errorMessage);
        }
      }
      return response.data;
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  // Error Handler
  static String handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return AppConstants.timeoutErrorMessage;

        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            return AppConstants.unauthorizedErrorMessage;
          } else if (error.response?.statusCode == 404) {
            return AppConstants.notFoundErrorMessage;
          } else if (error.response?.statusCode != null &&
              error.response!.statusCode! >= 500) {
            return AppConstants.serverErrorMessage;
          }

          // محاولة استخراج رسالة الخطأ من الاستجابة
          if (error.response?.data is Map<String, dynamic>) {
            final errorData = error.response!.data as Map<String, dynamic>;
            return errorData['message'] ?? AppConstants.unknownErrorMessage;
          }
          return AppConstants.unknownErrorMessage;

        case DioExceptionType.cancel:
          return 'تم إلغاء الطلب';

        case DioExceptionType.unknown:
        default:
          return AppConstants.networkErrorMessage;
      }
    } else if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }

    return AppConstants.unknownErrorMessage;
  }
}
