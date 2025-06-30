import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_constants.dart';
import '../models/base_response_model.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  static final Dio _dio = ApiConfig.dio;

  // جلب قائمة المواعيد مع فلترة
  static Future<PaginatedResponse<AppointmentModel>> getAppointments({
    int page = 1,
    int pageSize = AppConstants.appointmentsPageSize,
    AppointmentFilterRequest? filter,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      // إضافة الفلاتر إذا وُجدت
      if (filter != null) {
        queryParams.addAll(filter.toQueryParams());
      }

      final response = await _dio.get(
        AppConstants.appointments,
        queryParameters: queryParams,
      );

      final responseData = ApiConfig.handleResponse(response)!;

      return PaginatedResponse<AppointmentModel>.fromJson(
        responseData,
        (json) => AppointmentModel.fromJson(json),
      );
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في جلب المواعيد: $e');
    }
  }

  // إنشاء موعد جديد
  static Future<BaseResponse<Map<String, dynamic>>> createAppointment(
    CreateAppointmentRequest request,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.appointments,
        data: request.toJson(),
      );

      return BaseResponse<Map<String, dynamic>>.fromJson(
        ApiConfig.handleResponse(response)!,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في حجز الموعد: $e');
    }
  }

  // تغيير حالة الموعد (للطبيب)
  static Future<BaseResponse<Map<String, dynamic>>> toggleAppointmentStatus(
    int appointmentId,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.appointmentToggleStatus,
        data: appointmentId,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return BaseResponse<Map<String, dynamic>>.fromJson(
        ApiConfig.handleResponse(response)!,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في تغيير حالة الموعد: $e');
    }
  }

  // إكمال الموعد (للطبيب)
  static Future<BaseResponse<Map<String, dynamic>>> completeAppointment(
    int appointmentId,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.appointmentComplete,
        data: appointmentId,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      return BaseResponse<Map<String, dynamic>>.fromJson(
        ApiConfig.handleResponse(response)!,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في إكمال الموعد: $e');
    }
  }

  // جلب مواعيد المريض الحالي
  static Future<List<AppointmentModel>> getMyAppointments({
    int? status,
  }) async {
    try {
      final userId = ApiConfig.getUserId();
      if (userId == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      final filter = AppointmentFilterRequest(
        userId: userId,
        status: status,
      );

      final response = await getAppointments(
        filter: filter,
        pageSize: 100, // جلب عدد كبير لمواعيد المستخدم
      );

      return response.items;
    } catch (e) {
      throw Exception('حدث خطأ في جلب مواعيدك: $e');
    }
  }

  // جلب مواعيد الطبيب (للطبيب الحالي)
  static Future<List<AppointmentModel>> getDoctorAppointments({
    int? doctorId,
    int? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final filter = AppointmentFilterRequest(
        doctorId: doctorId,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
      );

      final response = await getAppointments(
        filter: filter,
        pageSize: 100, // جلب عدد كبير للطبيب
      );

      return response.items;
    } catch (e) {
      throw Exception('حدث خطأ في جلب مواعيد العيادة: $e');
    }
  }

  // جلب المواعيد القادمة
  static Future<List<AppointmentModel>> getUpcomingAppointments() async {
    try {
      // ignore: unused_local_variable
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      final filter = AppointmentFilterRequest(
        fromDate: DateTime.now(),
        status: AppConstants.appointmentStatusApproved,
      );

      final response = await getAppointments(filter: filter);

      // فلترة المواعيد القادمة فقط
      return response.items
          .where((appointment) =>
              appointment.appointmentDate.isAfter(DateTime.now()))
          .toList();
    } catch (e) {
      throw Exception('حدث خطأ في جلب المواعيد القادمة: $e');
    }
  }

  // جلب المواعيد المكتملة
  static Future<List<AppointmentModel>> getCompletedAppointments() async {
    try {
      final filter = AppointmentFilterRequest(
        status: AppConstants.appointmentStatusCompleted,
      );

      final response = await getAppointments(filter: filter);
      return response.items;
    } catch (e) {
      throw Exception('حدث خطأ في جلب المواعيد المكتملة: $e');
    }
  }

  // جلب طلبات الحجز المعلقة (للطبيب)
  static Future<List<AppointmentModel>> getPendingAppointments({
    int? doctorId,
  }) async {
    try {
      final filter = AppointmentFilterRequest(
        doctorId: doctorId,
        status: AppConstants.appointmentStatusPending,
      );

      final response = await getAppointments(filter: filter);
      return response.items;
    } catch (e) {
      throw Exception('حدث خطأ في جلب طلبات الحجز: $e');
    }
  }

  // جلب مواعيد اليوم
  static Future<List<AppointmentModel>> getTodayAppointments({
    int? doctorId,
  }) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final filter = AppointmentFilterRequest(
        doctorId: doctorId,
        fromDate: startOfDay,
        toDate: endOfDay,
        status: AppConstants.appointmentStatusApproved,
      );

      final response = await getAppointments(filter: filter);
      return response.items;
    } catch (e) {
      throw Exception('حدث خطأ في جلب مواعيد اليوم: $e');
    }
  }

  // التحقق من توفر موعد
  static Future<bool> isAppointmentAvailable(
    int doctorId,
    DateTime appointmentDate,
  ) async {
    try {
      // جلب مواعيد الطبيب في نفس اليوم
      final startOfDay = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final filter = AppointmentFilterRequest(
        doctorId: doctorId,
        fromDate: startOfDay,
        toDate: endOfDay,
      );

      final response = await getAppointments(filter: filter);

      // TODO: التحقق من الحد الأقصى للمواعيد حسب جدول الطبيب
      // حالياً نفترض أن الموعد متاح إذا لم يكن هناك موعد في نفس الوقت

      return response.items.length < 50; // حد مؤقت
    } catch (e) {
      throw Exception('حدث خطأ في التحقق من توفر الموعد: $e');
    }
  }

  // إحصائيات المواعيد (للطبيب)
  static Future<Map<String, int>> getAppointmentStats({int? doctorId}) async {
    try {
      final filter = AppointmentFilterRequest(doctorId: doctorId);
      final response = await getAppointments(filter: filter, pageSize: 1000);

      final stats = <String, int>{
        'total': response.items.length,
        'pending': 0,
        'approved': 0,
        'rejected': 0,
        'completed': 0,
      };

      for (final appointment in response.items) {
        switch (appointment.status) {
          case AppConstants.appointmentStatusPending:
            stats['pending'] = stats['pending']! + 1;
            break;
          case AppConstants.appointmentStatusApproved:
            stats['approved'] = stats['approved']! + 1;
            break;
          case AppConstants.appointmentStatusRejected:
            stats['rejected'] = stats['rejected']! + 1;
            break;
          case AppConstants.appointmentStatusCompleted:
            stats['completed'] = stats['completed']! + 1;
            break;
        }
      }

      return stats;
    } catch (e) {
      throw Exception('حدث خطأ في جلب إحصائيات المواعيد: $e');
    }
  }

  // TODO: إضافة هذه الدوال عندما تصبح APIs متوفرة

  // تعديل موعد
  // static Future<BaseResponse<AppointmentModel>> updateAppointment(
  //   int appointmentId,
  //   Map<String, dynamic> updates,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // إلغاء موعد
  // static Future<BaseResponse<void>> cancelAppointment(
  //   int appointmentId,
  //   String? reason,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // موافقة الطبيب على الموعد
  // static Future<BaseResponse<void>> approveAppointment(
  //   int appointmentId,
  //   double? paymentAmount,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // رفض الطبيب للموعد
  // static Future<BaseResponse<void>> rejectAppointment(
  //   int appointmentId,
  //   String? reason,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // تحديث حالة الدفع
  // static Future<BaseResponse<void>> updatePaymentStatus(
  //   int appointmentId,
  //   int paymentStatus,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // جلب تاريخ المواعيد للمريض
  // static Future<List<AppointmentModel>> getPatientHistory(
  //   String patientId,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // إرسال تذكير بالموعد
  // static Future<BaseResponse<void>> sendAppointmentReminder(
  //   int appointmentId,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }
}
