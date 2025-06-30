import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/constants/app_constants.dart';
import '../models/specialization_model.dart';

class GeneralService {
  static final Dio _dio = ApiConfig.dio;

  // Cache للبيانات الثابتة
  static List<SpecializationModel>? _cachedSpecializations;
  static List<DayModel>? _cachedDays;
  static DateTime? _lastCacheUpdate;

  // مدة انتهاء الـ Cache (24 ساعة)
  static const Duration _cacheValidDuration = Duration(hours: 24);

  // التحقق من صلاحية الـ Cache
  static bool get _isCacheValid {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheValidDuration;
  }

  // جلب جميع التخصصات الطبية
  static Future<List<SpecializationModel>> getSpecializations({
    bool forceRefresh = false,
  }) async {
    try {
      // استخدام الـ Cache إذا كان صالحاً
      if (!forceRefresh && _isCacheValid && _cachedSpecializations != null) {
        return _cachedSpecializations!;
      }

      final response = await _dio.get(AppConstants.specializations);
      final responseData = ApiConfig.handleResponse(response)!;

      final specializations = (responseData['data'] as List<dynamic>)
          .map((item) => SpecializationModel.fromJson(item))
          .toList();

      // حفظ في الـ Cache
      _cachedSpecializations = specializations;
      _lastCacheUpdate = DateTime.now();

      return specializations;
    } on DioException catch (e) {
      // إذا فشل الطلب وتوفر Cache، استخدمه
      if (_cachedSpecializations != null) {
        return _cachedSpecializations!;
      }
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في جلب التخصصات: $e');
    }
  }

  // جلب تخصص محدد
  static Future<SpecializationModel?> getSpecializationById(int id) async {
    try {
      final specializations = await getSpecializations();
      return specializations.firstWhere(
        (spec) => spec.id == id,
        orElse: () => throw Exception('التخصص غير موجود'),
      );
    } catch (e) {
      return null;
    }
  }

  // البحث في التخصصات
  static Future<List<SpecializationModel>> searchSpecializations(
    String searchText,
  ) async {
    try {
      final specializations = await getSpecializations();

      if (searchText.isEmpty) return specializations;

      return specializations
          .where((spec) =>
              spec.name.toLowerCase().contains(searchText.toLowerCase()) ||
              spec.normalizedName
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('حدث خطأ في البحث: $e');
    }
  }

  // جلب جميع أيام الأسبوع
  static Future<List<DayModel>> getDays({bool forceRefresh = false}) async {
    try {
      // استخدام الـ Cache إذا كان صالحاً
      if (!forceRefresh && _isCacheValid && _cachedDays != null) {
        return _cachedDays!;
      }

      final response = await _dio.get(AppConstants.days);
      final responseData = ApiConfig.handleResponse(response)!;

      final days = (responseData['data'] as List<dynamic>)
          .map((item) => DayModel.fromJson(item))
          .toList();

      // ترتيب الأيام (السبت = 1 أولاً)
      days.sort((a, b) => a.id.compareTo(b.id));

      // حفظ في الـ Cache
      _cachedDays = days;
      _lastCacheUpdate = DateTime.now();

      return days;
    } on DioException catch (e) {
      // إذا فشل الطلب وتوفر Cache، استخدمه
      if (_cachedDays != null) {
        return _cachedDays!;
      }
      throw Exception(ApiConfig.handleError(e));
    } catch (e) {
      throw Exception('حدث خطأ في جلب الأيام: $e');
    }
  }

  // جلب يوم محدد
  static Future<DayModel?> getDayById(int id) async {
    try {
      final days = await getDays();
      return days.firstWhere(
        (day) => day.id == id,
        orElse: () => throw Exception('اليوم غير موجود'),
      );
    } catch (e) {
      return null;
    }
  }

  // الحصول على اليوم الحالي
  static Future<DayModel?> getCurrentDay() async {
    try {
      final days = await getDays();
      final now = DateTime.now();

      // تحويل يوم الأسبوع إلى ID (Saturday = 1)
      int dayId;
      switch (now.weekday) {
        case DateTime.saturday:
          dayId = 1;
          break;
        case DateTime.sunday:
          dayId = 2;
          break;
        case DateTime.monday:
          dayId = 3;
          break;
        case DateTime.tuesday:
          dayId = 4;
          break;
        case DateTime.wednesday:
          dayId = 5;
          break;
        case DateTime.thursday:
          dayId = 6;
          break;
        case DateTime.friday:
          dayId = 7;
          break;
        default:
          dayId = 1;
      }

      return days.firstWhere(
        (day) => day.id == dayId,
        orElse: () => days.first,
      );
    } catch (e) {
      return null;
    }
  }

  // جلب أيام العمل (السبت إلى الخميس)
  static Future<List<DayModel>> getWorkDays() async {
    try {
      final days = await getDays();
      // استثناء الجمعة (id = 7)
      return days.where((day) => day.id != 7).toList();
    } catch (e) {
      throw Exception('حدث خطأ في جلب أيام العمل: $e');
    }
  }

  // الحصول على أيام نهاية الأسبوع
  static Future<List<DayModel>> getWeekendDays() async {
    try {
      final days = await getDays();
      // الجمعة والسبت (حسب المنطقة)
      return days.where((day) => day.id == 7 || day.id == 1).toList();
    } catch (e) {
      throw Exception('حدث خطأ في جلب أيام نهاية الأسبوع: $e');
    }
  }

  // تحديث الـ Cache يدوياً
  static Future<void> refreshCache() async {
    try {
      await Future.wait([
        getSpecializations(forceRefresh: true),
        getDays(forceRefresh: true),
      ]);
    } catch (e) {
      throw Exception('حدث خطأ في تحديث البيانات: $e');
    }
  }

  // مسح الـ Cache
  static void clearCache() {
    _cachedSpecializations = null;
    _cachedDays = null;
    _lastCacheUpdate = null;
  }

  // إحصائيات عامة
  static Future<Map<String, dynamic>> getGeneralStats() async {
    try {
      final specializations = await getSpecializations();
      final days = await getDays();

      return {
        'totalSpecializations': specializations.length,
        'totalDays': days.length,
        'cacheLastUpdate': _lastCacheUpdate?.toIso8601String(),
        'isCacheValid': _isCacheValid,
        'mostCommonSpecializations':
            _getMostCommonSpecializations(specializations),
      };
    } catch (e) {
      throw Exception('حدث خطأ في جلب الإحصائيات: $e');
    }
  }

  // الحصول على أكثر التخصصات شيوعاً (مؤقتاً حسب الترتيب)
  static List<Map<String, dynamic>> _getMostCommonSpecializations(
    List<SpecializationModel> specializations,
  ) {
    // ترتيب مؤقت حسب الأهمية المفترضة
    final commonSpecs = [
      'أخصائي باطنية',
      'أخصائي أطفال',
      'أخصائي قلب',
      'أخصائي نسائية وتوليد',
      'أخصائي جراحة عامة',
    ];

    return specializations
        .where((spec) => commonSpecs.contains(spec.name))
        .map((spec) => {
              'id': spec.id,
              'name': spec.name,
              'normalizedName': spec.normalizedName,
            })
        .toList();
  }

  // التحقق من اتصال الإنترنت
  static Future<bool> checkInternetConnection() async {
    try {
      final response = await _dio.get(
        AppConstants.specializations,
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // معلومات الخادم
  static Future<Map<String, dynamic>> getServerInfo() async {
    try {
      // محاولة جلب أي endpoint للتحقق من حالة الخادم
      // ignore: unused_local_variable
      final response = await _dio.get(AppConstants.specializations);

      return {
        'isOnline': true,
        'responseTime': DateTime.now().millisecondsSinceEpoch,
        'serverStatus': 'متصل',
        'lastCheck': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'isOnline': false,
        'responseTime': null,
        'serverStatus': 'غير متصل',
        'lastCheck': DateTime.now().toIso8601String(),
        'error': e.toString(),
      };
    }
  }

  // تنظيف الموارد
  static void dispose() {
    clearCache();
  }
}
