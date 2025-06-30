import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/general_service.dart';
import '../data/models/specialization_model.dart';
import '../core/utils/app_utils.dart';
import '../core/config/api_config.dart';

class GeneralController extends GetxController {
  // Loading States
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isCheckingConnection = false.obs;

  // Data Lists
  final RxList<SpecializationModel> specializations =
      <SpecializationModel>[].obs;
  final RxList<DayModel> days = <DayModel>[].obs;

  // App State
  final RxBool isOnline = true.obs;
  final RxBool isFirstTime = true.obs;
  final RxString appVersion = '1.0.0'.obs;
  final RxInt currentOnboardingPage = 0.obs;

  // Navigation
  final RxInt currentBottomNavIndex = 0.obs;
  final RxString currentRoute = '/'.obs;

  // Search
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  // Theme & Settings
  final RxBool isDarkMode = false.obs;
  final RxString selectedLanguage = 'ar'.obs;

  // Statistics
  final RxMap<String, dynamic> generalStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
    _setupSearchListener();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // تهيئة التطبيق
  Future<void> _initializeApp() async {
    await _checkFirstTime();
    await _loadBasicData();
    await _checkInternetConnection();
  }

  // إعداد مستمع البحث
  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  // التحقق من المرة الأولى لفتح التطبيق
  Future<void> _checkFirstTime() async {
    isFirstTime.value = ApiConfig.isFirstTime();
  }

  // تحميل البيانات الأساسية
  Future<void> _loadBasicData() async {
    try {
      isLoading.value = true;

      await Future.wait([
        loadSpecializations(),
        loadDays(),
      ]);

      await loadGeneralStats();
    } catch (e) {
      AppUtils.logError('فشل في تحميل البيانات الأساسية', e);
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل التخصصات
  Future<void> loadSpecializations({bool forceRefresh = false}) async {
    try {
      final specs = await GeneralService.getSpecializations(
        forceRefresh: forceRefresh,
      );
      specializations.assignAll(specs);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل التخصصات');
    }
  }

  // تحميل الأيام
  Future<void> loadDays({bool forceRefresh = false}) async {
    try {
      final daysList = await GeneralService.getDays(
        forceRefresh: forceRefresh,
      );
      days.assignAll(daysList);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل الأيام');
    }
  }

  // تحميل الإحصائيات العامة
  Future<void> loadGeneralStats() async {
    try {
      final stats = await GeneralService.getGeneralStats();
      generalStats.assignAll(stats);
    } catch (e) {
      AppUtils.logError('فشل في تحميل الإحصائيات العامة', e);
    }
  }

  // التحقق من اتصال الإنترنت
  Future<void> _checkInternetConnection() async {
    try {
      isCheckingConnection.value = true;

      final hasConnection = await GeneralService.checkInternetConnection();
      isOnline.value = hasConnection;

      if (!hasConnection) {
        AppUtils.showWarningSnackbar(
            'لا يوجد اتصال', 'تحقق من اتصالك بالإنترنت');
      }
    } catch (e) {
      isOnline.value = false;
    } finally {
      isCheckingConnection.value = false;
    }
  }

  // تحديث البيانات
  Future<void> refreshData() async {
    try {
      isRefreshing.value = true;

      await GeneralService.refreshCache();
      await _loadBasicData();

      AppUtils.showSuccessSnackbar('تم التحديث', 'تم تحديث البيانات بنجاح');
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحديث البيانات');
    } finally {
      isRefreshing.value = false;
    }
  }

  // البحث في التخصصات
  Future<List<SpecializationModel>> searchSpecializations(String query) async {
    try {
      isSearching.value = true;

      final results = await GeneralService.searchSpecializations(query);
      return results;
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في البحث');
      return [];
    } finally {
      isSearching.value = false;
    }
  }

  // الحصول على تخصص بالمعرف
  SpecializationModel? getSpecializationById(int id) {
    try {
      return specializations.firstWhere((spec) => spec.id == id);
    } catch (e) {
      return null;
    }
  }

  // الحصول على يوم بالمعرف
  DayModel? getDayById(int id) {
    try {
      return days.firstWhere((day) => day.id == id);
    } catch (e) {
      return null;
    }
  }

  // الحصول على اليوم الحالي
  Future<DayModel?> getCurrentDay() async {
    try {
      return await GeneralService.getCurrentDay();
    } catch (e) {
      return null;
    }
  }

  // الحصول على أيام العمل
  Future<List<DayModel>> getWorkDays() async {
    try {
      return await GeneralService.getWorkDays();
    } catch (e) {
      return [];
    }
  }

  // تعيين المرة الأولى كمكتملة
  void completeFirstTime() {
    isFirstTime.value = false;
    ApiConfig.setFirstTime(false);
  }

  // تغيير صفحة الـ Onboarding
  void setOnboardingPage(int page) {
    currentOnboardingPage.value = page;
  }

  // الانتقال للصفحة التالية في الـ Onboarding
  void nextOnboardingPage() {
    if (currentOnboardingPage.value < 2) {
      currentOnboardingPage.value++;
    } else {
      completeFirstTime();
      Get.offAllNamed('/home');
    }
  }

  // تخطي الـ Onboarding
  void skipOnboarding() {
    completeFirstTime();
    Get.offAllNamed('/home');
  }

  // تغيير تبويب الشريط السفلي
  void changeBottomNavIndex(int index) {
    currentBottomNavIndex.value = index;
  }

  // تحديث المسار الحالي
  void updateCurrentRoute(String route) {
    currentRoute.value = route;
  }

  // مسح البحث
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  // تبديل الوضع المظلم
  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    // TODO: حفظ الإعداد محلياً
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // تغيير اللغة
  void changeLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
    // TODO: تطبيق تغيير اللغة
    // Get.updateLocale(Locale(languageCode));
  }

  // إظهار معلومات الخادم
  Future<void> showServerInfo() async {
    try {
      final serverInfo = await GeneralService.getServerInfo();

      Get.dialog(
        AlertDialog(
          title: const Text('معلومات الخادم'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الحالة: ${serverInfo['serverStatus']}'),
              Text('آخر فحص: ${serverInfo['lastCheck']}'),
              if (serverInfo['responseTime'] != null)
                Text('وقت الاستجابة: ${serverInfo['responseTime']} ms'),
              if (serverInfo['error'] != null)
                Text('الخطأ: ${serverInfo['error']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      );
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في جلب معلومات الخادم');
    }
  }

  // إظهار الإحصائيات العامة
  void showGeneralStats() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إحصائيات التطبيق',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (generalStats.isNotEmpty) ...[
              _buildStatRow(
                  'عدد التخصصات', '${generalStats['totalSpecializations']}'),
              _buildStatRow('عدد الأيام', '${generalStats['totalDays']}'),
              _buildStatRow(
                  'صالحية الذاكرة المؤقتة', '${generalStats['isCacheValid']}'),
              if (generalStats['cacheLastUpdate'] != null)
                _buildStatRow(
                    'آخر تحديث للذاكرة', '${generalStats['cacheLastUpdate']}'),
            ] else
              const Text('لا توجد إحصائيات متاحة'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('إغلاق'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      refreshData();
                    },
                    child: const Text('تحديث البيانات'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // بناء صف الإحصائية
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // مسح الذاكرة المؤقتة
  void clearCache() {
    GeneralService.clearCache();
    AppUtils.showSuccessSnackbar('تم المسح', 'تم مسح الذاكرة المؤقتة');
  }

  // إعادة تشغيل التطبيق
  void restartApp() {
    Get.dialog(
      AlertDialog(
        title: const Text('إعادة تشغيل التطبيق'),
        content: const Text('هل تريد إعادة تشغيل التطبيق؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: إعادة تشغيل التطبيق
              Get.offAllNamed('/splash');
            },
            child: const Text('إعادة تشغيل'),
          ),
        ],
      ),
    );
  }

  // إظهار معلومات التطبيق
  void showAboutApp() {
    Get.dialog(
      AlertDialog(
        title: const Text('حول التطبيق'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الإصدار: ${appVersion.value}'),
            const Text('تطبيق حجز المواعيد الطبية'),
            const SizedBox(height: 8),
            const Text('تم تطويره بـ Flutter'),
            const Text('نظام إدارة الحالة: GetX'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // التحقق من التحديثات
  Future<void> checkForUpdates() async {
    AppUtils.showLoadingDialog();

    // محاكاة فحص التحديثات
    await Future.delayed(const Duration(seconds: 2));

    AppUtils.hideLoadingDialog();

    AppUtils.showInfoSnackbar(
        'لا توجد تحديثات', 'أنت تستخدم أحدث إصدار من التطبيق');
  }

  // تنظيف الموارد
  @override
  void dispose() {
    super.dispose();
    GeneralService.dispose();
  }
}
