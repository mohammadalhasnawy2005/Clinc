import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_constants.dart';
import '../models/base_response_model.dart';
import '../models/subscription_models.dart';

class SubscriptionService {
  static final Dio _dio = ApiConfig.dio;

  // جلب جميع باقات الاشتراك المتاحة
  static Future<List<SubscriptionPackageModel>>
      getSubscriptionPackages() async {
    try {
      final response = await _dio.get(
        AppConstants.subscriptionPackages,
        queryParameters: {
          'page': 1,
          'pageSize': 50, // جلب جميع الباقات
        },
      );

      final responseData = ApiConfig.handleResponse(response)!;
      final paginatedData = responseData['data'] as Map<String, dynamic>;

      final packages = (paginatedData['items'] as List<dynamic>)
          .map((item) => SubscriptionPackageModel.fromJson(item))
          .toList();

      // ترتيب الباقات حسب السعر
      packages.sort((a, b) => a.price.compareTo(b.price));

      return packages;
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في جلب باقات الاشتراك: $e');
    }
  }

  // جلب باقة اشتراك محددة
  static Future<SubscriptionPackageModel?> getPackageById(int packageId) async {
    try {
      final packages = await getSubscriptionPackages();
      return packages.firstWhere(
        (package) => package.id == packageId,
        orElse: () => throw Exception('الباقة غير موجودة'),
      );
    } catch (e) {
      throw Exception('حدث خطأ في جلب تفاصيل الباقة: $e');
    }
  }

  // جلب اشتراكات الطبيب
  static Future<List<DoctorSubscriptionModel>> getDoctorSubscriptions({
    int? doctorId,
    int? packageId,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': 1,
        'pageSize': 100,
      };

      if (doctorId != null) queryParams['DoctorId'] = doctorId;
      if (packageId != null) queryParams['PackageId'] = packageId;
      if (isActive != null) queryParams['IsActive'] = isActive;

      final response = await _dio.get(
        AppConstants.doctorSubscription,
        queryParameters: queryParams,
      );

      final responseData = ApiConfig.handleResponse(response)!;
      final paginatedData = responseData['data'] as Map<String, dynamic>;

      return (paginatedData['items'] as List<dynamic>)
          .map((item) => DoctorSubscriptionModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في جلب اشتراكات الطبيب: $e');
    }
  }

  // إنشاء اشتراك جديد
  static Future<BaseResponse<Map<String, dynamic>>> createSubscription(
    CreateSubscriptionRequest request,
  ) async {
    try {
      final response = await _dio.post(
        AppConstants.doctorSubscription,
        data: request.toJson(),
      );

      return BaseResponse<Map<String, dynamic>>.fromJson(
        ApiConfig.handleResponse(response)!,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في إنشاء الاشتراك: $e');
    }
  }

  // جلب جميع الميزات المتاحة
  static Future<List<FeatureModel>> getFeatures() async {
    try {
      final response = await _dio.get(AppConstants.features);

      final responseData = ApiConfig.handleResponse(response)!;

      return (responseData['data'] as List<dynamic>)
          .map((item) => FeatureModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في جلب الميزات: $e');
    }
  }

  // جلب ميزات طبيب محدد
  static Future<List<DoctorFeatureModel>> getDoctorFeatures({
    int? doctorId,
    int? featureId,
    bool? isEnabled,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': 1,
        'pageSize': 100,
      };

      if (doctorId != null) queryParams['DoctorId'] = doctorId;
      if (featureId != null) queryParams['Id'] = featureId;

      final response = await _dio.get(
        AppConstants.doctorFeature,
        queryParameters: queryParams,
      );

      final responseData = ApiConfig.handleResponse(response)!;
      final paginatedData = responseData['data'] as Map<String, dynamic>;

      final features = (paginatedData['items'] as List<dynamic>)
          .map((item) => DoctorFeatureModel.fromJson(item))
          .toList();

      // فلترة الميزات المفعلة إذا طُلب ذلك
      if (isEnabled != null) {
        return features
            .where((feature) => feature.isEnabled == isEnabled)
            .toList();
      }

      return features;
    } on DioException catch (e) {
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في جلب ميزات الطبيب: $e');
    }
  }

  // جلب الاشتراك النشط للطبيب
  static Future<DoctorSubscriptionModel?> getActiveDoctorSubscription(
    int doctorId,
  ) async {
    try {
      final subscriptions = await getDoctorSubscriptions(
        doctorId: doctorId,
        isActive: true,
      );

      if (subscriptions.isNotEmpty) {
        // إرجاع أحدث اشتراك نشط
        subscriptions.sort((a, b) => b.startDate.compareTo(a.startDate));
        return subscriptions.first;
      }

      return null;
    } catch (e) {
      throw Exception('حدث خطأ في جلب الاشتراك النشط: $e');
    }
  }

  // التحقق من صلاحية الاشتراك
  static Future<bool> isSubscriptionValid(int doctorId) async {
    try {
      final subscription = await getActiveDoctorSubscription(doctorId);

      if (subscription == null) return false;

      return subscription.isActive && !subscription.isExpired;
    } catch (e) {
      return false; // في حالة الخطأ، اعتبر الاشتراك غير صالح
    }
  }

  // التحقق من إمكانية الطبيب استخدام ميزة معينة
  static Future<bool> canDoctorUseFeature(
    int doctorId,
    String featureNormalizedName,
  ) async {
    try {
      // جلب الاشتراك النشط
      final subscription = await getActiveDoctorSubscription(doctorId);
      if (subscription == null || subscription.isExpired) return false;

      // التحقق من أن الباقة تدعم الميزة
      final package = subscription.package;

      switch (featureNormalizedName.toLowerCase()) {
        case 'showreviews':
          return package.showReviews;
        case 'showmessages':
          return package.showMessages;
        case 'ebooking':
          return package.eBooking;
        case 'epayments':
          return package.ePayments;
        case 'makeoffers':
          return package.makeOffers;
        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  // حساب الأرباح المحتملة للباقة
  static Map<String, double> calculatePackageSavings(
    SubscriptionPackageModel package,
  ) {
    final monthlyTotal = package.price * 12;
    final yearlyPrice = package.yearlyPrice;
    final savings = monthlyTotal - yearlyPrice;
    final savingsPercentage = savings > 0 ? (savings / monthlyTotal) * 100 : 0;

    return {
      'monthlyTotal': monthlyTotal,
      'yearlyPrice': yearlyPrice,
      'savings': savings,
      'savingsPercentage': savingsPercentage.toDouble(),
    };
  }

  // مقارنة الباقات
  static Map<String, dynamic> comparePackages(
    SubscriptionPackageModel current,
    SubscriptionPackageModel target,
  ) {
    return {
      'priceDifference': target.price - current.price,
      'yearlyPriceDifference': target.yearlyPrice - current.yearlyPrice,
      'additionalAppointments':
          target.maxDailyAppointments - current.maxDailyAppointments,
      'additionalDays': target.maxWeeklyDays - current.maxWeeklyDays,
      'newFeatures': {
        'showReviews': target.showReviews && !current.showReviews,
        'showMessages': target.showMessages && !current.showMessages,
        'eBooking': target.eBooking && !current.eBooking,
        'ePayments': target.ePayments && !current.ePayments,
        'makeOffers': target.makeOffers && !current.makeOffers,
      },
      'additionalOffers': target.maxActiveOffers - current.maxActiveOffers,
    };
  }

  // جلب إحصائيات الاشتراكات (للتحليل)
  static Future<Map<String, dynamic>> getSubscriptionStats() async {
    try {
      final packages = await getSubscriptionPackages();
      final subscriptions = await getDoctorSubscriptions();

      final stats = <String, dynamic>{
        'totalPackages': packages.length,
        'totalSubscriptions': subscriptions.length,
        'activeSubscriptions': subscriptions.where((s) => s.isActive).length,
        'packageDistribution': <String, int>{},
        'averagePrice': 0.0,
        'mostPopularPackage': null,
      };

      // توزيع الباقات
      for (final subscription in subscriptions) {
        final packageName = subscription.package.name;
        stats['packageDistribution'][packageName] =
            (stats['packageDistribution'][packageName] ?? 0) + 1;
      }

      // متوسط السعر
      if (packages.isNotEmpty) {
        final totalPrice = packages.fold<double>(0, (sum, p) => sum + p.price);
        stats['averagePrice'] = totalPrice / packages.length;
      }

      // الباقة الأكثر شعبية
      if (stats['packageDistribution'].isNotEmpty) {
        final distribution = stats['packageDistribution'] as Map<String, int>;
        final mostPopular = distribution.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );
        stats['mostPopularPackage'] = mostPopular.key;
      }

      return stats;
    } catch (e) {
      throw Exception('حدث خطأ في جلب إحصائيات الاشتراكات: $e');
    }
  }

  // TODO: إضافة هذه الدوال عندما تصبح APIs متوفرة

  // تحديث اشتراك
  // static Future<BaseResponse<DoctorSubscriptionModel>> updateSubscription(
  //   int subscriptionId,
  //   int newPackageId,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // إلغاء اشتراك
  // static Future<BaseResponse<void>> cancelSubscription(
  //   int subscriptionId,
  //   String? reason,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // تفعيل/إلغاء ميزة للطبيب
  // static Future<BaseResponse<void>> toggleDoctorFeature(
  //   int doctorId,
  //   int featureId,
  //   bool isEnabled,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // معالجة الدفع
  // static Future<BaseResponse<void>> processPayment(
  //   int subscriptionId,
  //   Map<String, dynamic> paymentDetails,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }

  // تجديد اشتراك
  // static Future<BaseResponse<DoctorSubscriptionModel>> renewSubscription(
  //   int subscriptionId,
  //   bool isYearly,
  // ) async {
  //   // سيتم تطويرها لاحقاً
  // }
}
