import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_constants.dart';
import '../models/base_response_model.dart';
import '../models/doctor_model.dart';

class DoctorService {
  static final Dio _dio = ApiConfig.dio;

  // جلب قائمة الأطباء مع فلترة
  static Future<PaginatedResponse<DoctorModel>> getDoctors({
    int page = 1,
    int pageSize = AppConstants.doctorsPageSize,
    int? specializationId,
    int? doctorId,
    String? name,
    int? iraqiProvince,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (specializationId != null) {
        queryParams['Specialization'] = specializationId;
      }
      if (doctorId != null) {
        queryParams['Id'] = doctorId;
      }
      if (name != null && name.isNotEmpty) {
        queryParams['Name'] = name;
      }
      if (iraqiProvince != null) {
        queryParams['IraqiProvince'] = iraqiProvince;
      }

      final response = await _dio.get(
        AppConstants.doctors,
        queryParameters: queryParams,
      );

      final responseData = ApiConfig.handleResponse(response)!;

      return PaginatedResponse<DoctorModel>.fromJson(
        responseData,
        (json) => DoctorModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في جلب الأطباء: $e');
    }
  }

  // جلب تفاصيل طبيب محدد
  static Future<DoctorModel?> getDoctorById(int doctorId) async {
    try {
      final response = await getDoctors(doctorId: doctorId, pageSize: 1);

      if (response.items.isNotEmpty) {
        return response.items.first;
      }
      return null;
    } catch (e) {
      throw Exception('حدث خطأ في جلب تفاصيل الطبيب: $e');
    }
  }

  // إنشاء طبيب/عيادة جديدة
  static Future<BaseResponse<Map<String, dynamic>>> createDoctor(
    CreateDoctorRequest request,
    String imagePath,
  ) async {
    try {
      final formData = FormData.fromMap({
        'Name': request.name,
        'NormalizedName': request.normalizedName,
        'SpecializationId': request.specializationId,
        'Description': request.description,
        'IraqiProvince': request.iraqiProvince,
        'BirthDay': request.birthDay,
        'PhoneNumber': request.phoneNumber,
        'Location': request.location,
        'ImageName': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        AppConstants.doctors,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      final baseResponse = BaseResponse<Map<String, dynamic>>.fromJson(
        ApiConfig.handleResponse(response)!,
        (json) => json as Map<String, dynamic>,
      );

      // إذا نجح إنشاء الطبيب، قم بتحديث نوع المستخدم
      if (baseResponse.isSuccess) {
        ApiConfig.saveUserType(AppConstants.userTypeDoctor);
      }

      return baseResponse;
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في إنشاء العيادة: $e');
    }
  }

  // جلب جدول أوقات الطبيب
  static Future<BaseResponse<List<DayAvailabilityModel>>> getDoctorAvailability(
    int doctorId,
  ) async {
    try {
      final response = await _dio.get(
        '${AppConstants.doctorAvailability}/$doctorId',
      );

      return BaseResponse<List<DayAvailabilityModel>>.fromJson(
        ApiConfig.handleResponse(response)!,
        (json) => (json as List<dynamic>)
            .map((item) => DayAvailabilityModel.fromJson(item))
            .toList(),
      );
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في جلب جدول الطبيب: $e');
    }
  }

  // تحديد أوقات عمل الطبيب
  static Future<BaseResponse<Map<String, dynamic>>> setDoctorAvailability(
    DoctorAvailabilityModel request,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.doctorAvailability,
        data: request.toJson(),
      );

      return BaseResponse<Map<String, dynamic>>.fromJson(
        ApiConfig.handleResponse(response)!,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في تحديد أوقات العمل: $e');
    }
  }

  // البحث في الأطباء بالنص
  static Future<List<DoctorModel>> searchDoctors(
    String searchText, {
    int? specializationId,
    int? iraqiProvince,
  }) async {
    try {
      final response = await getDoctors(
        name: searchText,
        specializationId: specializationId,
        iraqiProvince: iraqiProvince,
        pageSize: 50, // عدد أكبر للبحث
      );

      return response.items;
    } catch (e) {
      throw Exception('حدث خطأ في البحث: $e');
    }
  }

  // جلب الأطباء القريبين (مؤقتاً حسب المحافظة)
  static Future<List<DoctorModel>> getNearbyDoctors(int iraqiProvince) async {
    try {
      final response = await getDoctors(
        iraqiProvince: iraqiProvince,
        pageSize: 20,
      );

      return response.items;
    } catch (e) {
      throw Exception('حدث خطأ في جلب الأطباء القريبين: $e');
    }
  }

  // جلب أفضل الأطباء (مؤقتاً حسب subscriptionRank)
  static Future<List<DoctorModel>> getTopDoctors() async {
    try {
      final response = await getDoctors(pageSize: 20);

      // ترتيب حسب subscriptionRank (الأعلى أولاً)
      final sortedDoctors = response.items;
      sortedDoctors
          .sort((a, b) => b.subscriptionRank.compareTo(a.subscriptionRank));

      return sortedDoctors.take(10).toList();
    } catch (e) {
      throw Exception('حدث خطأ في جلب أفضل الأطباء: $e');
    }
  }

  // جلب الأطباء حسب التخصص
  static Future<List<DoctorModel>> getDoctorsBySpecialization(
    int specializationId,
  ) async {
    try {
      final response = await getDoctors(
        specializationId: specializationId,
        pageSize: 50,
      );

      return response.items;
    } catch (e) {
      throw Exception('حدث خطأ في جلب أطباء التخصص: $e');
    }
  }

  // TODO: إضافة هذه الدوال عندما تصبح APIs متوفرة

  // تحديث بيانات الطبيب
  // static Future<BaseResponse<DoctorModel>> updateDoctor(
  //   int doctorId,
  //   Map<String, dynamic> updates,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // حذف طبيب/عيادة
  // static Future<BaseResponse<void>> deleteDoctor(int doctorId) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // جلب عيادات الطبيب (للطبيب الواحد أكثر من عيادة)
  // static Future<List<DoctorModel>> getDoctorClinics() async {
  //   // سيتم تطويرها لاحقاً
  // }

  // تقييم الطبيب
  // static Future<BaseResponse<void>> rateDoctor(
  //   int doctorId,
  //   int rating,
  //   String? review,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // جلب تقييمات الطبيب
  // static Future<List<ReviewModel>> getDoctorReviews(int doctorId) async {
  //   // سيتم تطويرها لاحقاً
  // }
}
