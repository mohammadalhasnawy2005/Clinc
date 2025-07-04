import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/general_service.dart';
import '../data/models/specialization_model.dart';
import '../core/utils/app_utils.dart';
import '../core/config/api_config.dart';

class GeneralController extends GetxController {
  static GeneralController get instance => Get.find();

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

  Future<void> _initializeApp() async {
    try {
      await _checkFirstTime();
      await _loadBasicData();
      await _checkInternetConnection();
    } catch (e) {
      print('Error initializing app: $e');
    }
  }

  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  Future<void> _checkFirstTime() async {
    try {
      isFirstTime.value = ApiConfig.isFirstTime();
    } catch (e) {
      print('Error checking first time: $e');
      isFirstTime.value = true;
    }
  }

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

  Future<void> loadGeneralStats() async {
    try {
      final stats = await GeneralService.getGeneralStats();
      generalStats.assignAll(stats);
    } catch (e) {
      AppUtils.logError('فشل في تحميل الإحصائيات العامة', e);
    }
  }

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

  SpecializationModel? getSpecializationById(int id) {
    try {
      return specializations.firstWhere((spec) => spec.id == id);
    } catch (e) {
      return null;
    }
  }

  DayModel? getDayById(int id) {
    try {
      return days.firstWhere((day) => day.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<DayModel?> getCurrentDay() async {
    try {
      return await GeneralService.getCurrentDay();
    } catch (e) {
      return null;
    }
  }

  Future<List<DayModel>> getWorkDays() async {
    try {
      return await GeneralService.getWorkDays();
    } catch (e) {
      return [];
    }
  }

  void completeFirstTime() {
    isFirstTime.value = false;
    ApiConfig.setFirstTime(false);
  }

  void setOnboardingPage(int page) {
    currentOnboardingPage.value = page;
  }

  void nextOnboardingPage() {
    if (currentOnboardingPage.value < 2) {
      currentOnboardingPage.value++;
    } else {
      completeFirstTime();
      Get.offAllNamed('/main-navigation');
    }
  }

  void skipOnboarding() {
    completeFirstTime();
    Get.offAllNamed('/main-navigation');
  }

  void changeBottomNavIndex(int index) {
    currentBottomNavIndex.value = index;
  }

  void updateCurrentRoute(String route) {
    currentRoute.value = route;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void changeLanguage(String languageCode) {
    selectedLanguage.value = languageCode;
  }

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

  void clearCache() {
    GeneralService.clearCache();
    AppUtils.showSuccessSnackbar('تم المسح', 'تم مسح الذاكرة المؤقتة');
  }

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
              Get.offAllNamed('/splash');
            },
            child: const Text('إعادة تشغيل'),
          ),
        ],
      ),
    );
  }

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

  Future<void> checkForUpdates() async {
    AppUtils.showLoadingDialog();

    await Future.delayed(const Duration(seconds: 2));

    AppUtils.hideLoadingDialog();

    AppUtils.showInfoSnackbar(
        'لا توجد تحديثات', 'أنت تستخدم أحدث إصدار من التطبيق');
  }

  @override
  void dispose() {
    super.dispose();
    GeneralService.dispose();
  }
}
