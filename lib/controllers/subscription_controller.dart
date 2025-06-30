import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/subscription_service.dart';
import '../data/models/subscription_models.dart';
import '../core/utils/app_utils.dart';
import '../core/constants/app_constants.dart';
import 'auth_controller.dart';

class SubscriptionController extends GetxController {
  // Loading States
  final RxBool isLoading = false.obs;
  final RxBool isLoadingPackages = false.obs;
  final RxBool isCreatingSubscription = false.obs;
  final RxBool isLoadingFeatures = false.obs;
  final RxBool isCheckingFeature = false.obs;

  // Data Lists
  final RxList<SubscriptionPackageModel> packages =
      <SubscriptionPackageModel>[].obs;
  final RxList<DoctorSubscriptionModel> doctorSubscriptions =
      <DoctorSubscriptionModel>[].obs;
  final RxList<FeatureModel> allFeatures = <FeatureModel>[].obs;
  final RxList<DoctorFeatureModel> doctorFeatures = <DoctorFeatureModel>[].obs;

  // Current Selection
  final Rx<SubscriptionPackageModel?> selectedPackage =
      Rx<SubscriptionPackageModel?>(null);
  final Rx<DoctorSubscriptionModel?> currentSubscription =
      Rx<DoctorSubscriptionModel?>(null);

  // Subscription Type (Monthly/Yearly)
  final RxBool isYearlySelected = false.obs;

  // Statistics
  final RxMap<String, dynamic> subscriptionStats = <String, dynamic>{}.obs;

  // Get AuthController
  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  // تهيئة البيانات
  Future<void> _initializeData() async {
    await Future.wait([
      loadSubscriptionPackages(),
      loadAllFeatures(),
    ]);

    if (_authController.isDoctor) {
      await loadDoctorSubscriptions();
      await loadSubscriptionStats();
    }
  }

  // تحميل جميع باقات الاشتراك
  Future<void> loadSubscriptionPackages() async {
    try {
      isLoadingPackages.value = true;

      final packagesList = await SubscriptionService.getSubscriptionPackages();
      packages.assignAll(packagesList);

      // تعيين الباقة الأساسية كاختيار افتراضي
      if (packages.isNotEmpty && selectedPackage.value == null) {
        selectedPackage.value = packages.first;
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل باقات الاشتراك');
    } finally {
      isLoadingPackages.value = false;
    }
  }

  // تحميل جميع الميزات
  Future<void> loadAllFeatures() async {
    try {
      isLoadingFeatures.value = true;

      final featuresList = await SubscriptionService.getFeatures();
      allFeatures.assignAll(featuresList);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل الميزات');
    } finally {
      isLoadingFeatures.value = false;
    }
  }

  // تحميل اشتراكات الطبيب
  Future<void> loadDoctorSubscriptions({int? doctorId}) async {
    try {
      isLoading.value = true;

      final subscriptions = await SubscriptionService.getDoctorSubscriptions(
        doctorId: doctorId,
        isActive: true,
      );

      doctorSubscriptions.assignAll(subscriptions);

      // تعيين الاشتراك النشط الحالي
      if (subscriptions.isNotEmpty) {
        currentSubscription.value = subscriptions.first;
        selectedPackage.value = subscriptions.first.package;
      }

      // تحميل ميزات الطبيب
      await loadDoctorFeatures(doctorId: doctorId);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل اشتراكات الطبيب');
    } finally {
      isLoading.value = false;
    }
  }

  // تحميل ميزات الطبيب
  Future<void> loadDoctorFeatures({int? doctorId}) async {
    try {
      final features = await SubscriptionService.getDoctorFeatures(
        doctorId: doctorId,
        isEnabled: true,
      );

      doctorFeatures.assignAll(features);
    } catch (e) {
      AppUtils.logError('فشل في تحميل ميزات الطبيب', e);
    }
  }

  // إنشاء اشتراك جديد
  Future<void> createSubscription(int doctorId, int packageId) async {
    try {
      isCreatingSubscription.value = true;

      final request = CreateSubscriptionRequest(
        doctorId: doctorId,
        packageId: packageId,
      );

      final response = await SubscriptionService.createSubscription(request);

      if (response.isSuccess) {
        AppUtils.showSuccessSnackbar(
            'نجح الاشتراك', 'تم تفعيل باقة الاشتراك بنجاح');

        // تحديث البيانات
        await loadDoctorSubscriptions(doctorId: doctorId);

        Get.back(); // الرجوع للصفحة السابقة
      } else {
        AppUtils.showErrorSnackbar('فشل الاشتراك', response.message);
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في الاشتراك', e.toString());
    } finally {
      isCreatingSubscription.value = false;
    }
  }

  // التحقق من صلاحية الاشتراك
  Future<bool> checkSubscriptionValidity(int doctorId) async {
    try {
      return await SubscriptionService.isSubscriptionValid(doctorId);
    } catch (e) {
      return false;
    }
  }

  // التحقق من إمكانية استخدام ميزة
  Future<bool> canUseFeature(int doctorId, String featureNormalizedName) async {
    try {
      isCheckingFeature.value = true;

      return await SubscriptionService.canDoctorUseFeature(
        doctorId,
        featureNormalizedName,
      );
    } catch (e) {
      return false;
    } finally {
      isCheckingFeature.value = false;
    }
  }

  // تحميل إحصائيات الاشتراكات
  Future<void> loadSubscriptionStats() async {
    try {
      final stats = await SubscriptionService.getSubscriptionStats();
      subscriptionStats.assignAll(stats);
    } catch (e) {
      AppUtils.logError('فشل في تحميل إحصائيات الاشتراكات', e);
    }
  }

  // اختيار باقة اشتراك
  void selectPackage(SubscriptionPackageModel package) {
    selectedPackage.value = package;
  }

  // تبديل نوع الاشتراك (شهري/سنوي)
  void toggleSubscriptionType() {
    isYearlySelected.value = !isYearlySelected.value;
  }

  // حساب السعر الحالي حسب النوع المختار
  double get currentPrice {
    if (selectedPackage.value == null) return 0.0;
    return isYearlySelected.value
        ? selectedPackage.value!.yearlyPrice
        : selectedPackage.value!.price;
  }

  // حساب الوفر السنوي
  double get yearlySavings {
    if (selectedPackage.value == null) return 0.0;
    final savings =
        SubscriptionService.calculatePackageSavings(selectedPackage.value!);
    return savings['savings'] ?? 0.0;
  }

  // نسبة الوفر السنوي
  double get yearlySavingsPercentage {
    if (selectedPackage.value == null) return 0.0;
    final savings =
        SubscriptionService.calculatePackageSavings(selectedPackage.value!);
    return savings['savingsPercentage'] ?? 0.0;
  }

  // مقارنة الباقات
  Map<String, dynamic> compareWithCurrentPackage(
      SubscriptionPackageModel targetPackage) {
    if (currentSubscription.value == null) {
      return {
        'isUpgrade': true,
        'priceDifference': targetPackage.price,
        'newFeatures': _getPackageFeatures(targetPackage),
      };
    }

    return SubscriptionService.comparePackages(
      currentSubscription.value!.package,
      targetPackage,
    );
  }

  // الحصول على ميزات الباقة
  Map<String, bool> _getPackageFeatures(SubscriptionPackageModel package) {
    return {
      'showReviews': package.showReviews,
      'showMessages': package.showMessages,
      'eBooking': package.eBooking,
      'ePayments': package.ePayments,
      'makeOffers': package.makeOffers,
    };
  }

  // التحقق من انتهاء صلاحية الاشتراك قريباً
  bool get isSubscriptionExpiringSoon {
    if (currentSubscription.value == null) return false;
    return currentSubscription.value!.isExpiringSoon;
  }

  // الحصول على عدد الأيام المتبقية
  int get daysRemaining {
    if (currentSubscription.value == null) return 0;
    return currentSubscription.value!.daysRemaining;
  }

  // التحقق من توفر ميزة معينة في الباقة الحالية
  bool isFeatureAvailable(String featureNormalizedName) {
    if (currentSubscription.value == null) return false;

    final package = currentSubscription.value!.package;

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
  }

  // الحصول على لون الباقة
  Color getPackageColor(int packageId) {
    return AppUtils.getPackageColor(packageId);
  }

  // الحصول على اسم الباقة
  String getPackageName(int packageId) {
    return AppUtils.getPackageNameText(packageId);
  }

  // التحقق من كون الباقة هي الأكثر شعبية
  bool isPackagePopular(SubscriptionPackageModel package) {
    // الباقة الذهبية هي الأكثر شعبية (افتراضياً)
    return package.id == AppConstants.packageGold;
  }

  // التحقق من كون الباقة موصى بها
  bool isPackageRecommended(SubscriptionPackageModel package) {
    // الباقة الألماس موصى بها (افتراضياً)
    return package.id == AppConstants.packageDiamond;
  }

  // الحصول على وصف الباقة
  String getPackageDescription(SubscriptionPackageModel package) {
    switch (package.id) {
      case AppConstants.packageBasic:
        return 'مثالية للبداية';
      case AppConstants.packageGold:
        return 'الأكثر شعبية';
      case AppConstants.packageDiamond:
        return 'موصى بها';
      case AppConstants.packagePremium:
        return 'للمحترفين';
      default:
        return '';
    }
  }

  // الحصول على قائمة الميزات لكل باقة
  List<String> getPackageFeaturesList(SubscriptionPackageModel package) {
    final features = <String>[
      '${package.maxDailyAppointments} موعد يومياً',
      '${package.maxWeeklyDays} أيام عمل أسبوعياً',
    ];

    if (package.showReviews) {
      features.add('عرض التقييمات والمراجعات');
    }

    if (package.showMessages) {
      features.add('نظام المحادثة مع المرضى');
    }

    if (package.eBooking) {
      features.add('الحجز الإلكتروني المتقدم');
    }

    if (package.ePayments) {
      features.add('نظام الدفع الإلكتروني');
    }

    if (package.makeOffers) {
      features.add('إنشاء العروض الطبية');
      if (package.maxActiveOffers > 0) {
        features.add('${package.maxActiveOffers} عرض نشط');
      }
    }

    return features;
  }

  // إظهار حوار تأكيد الاشتراك
  void showSubscriptionConfirmDialog(
      int doctorId, SubscriptionPackageModel package) {
    final price = isYearlySelected.value ? package.yearlyPrice : package.price;
    final period = isYearlySelected.value ? 'سنوياً' : 'شهرياً';

    Get.dialog(
      AlertDialog(
        title: Text('تأكيد الاشتراك في ${package.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('السعر: ${AppUtils.formatPrice(price)} $period'),
            if (isYearlySelected.value && yearlySavings > 0)
              Text(
                'توفر: ${AppUtils.formatPrice(yearlySavings)} (${yearlySavingsPercentage.toStringAsFixed(0)}%)',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
            const Text('الميزات المشمولة:'),
            ...getPackageFeaturesList(package).map(
              (feature) => Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(feature,
                            style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              createSubscription(doctorId, package.id);
            },
            child: const Text('تأكيد الاشتراك'),
          ),
        ],
      ),
    );
  }

  // إظهار معلومات الباقة
  void showPackageDetails(SubscriptionPackageModel package) {
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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: getPackageColor(package.id),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.star, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        getPackageDescription(package),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'الميزات:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...getPackageFeaturesList(package).map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                      selectPackage(package);
                    },
                    child: const Text('اختيار هذه الباقة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // التحقق من إمكانية الترقية
  bool canUpgradePackage() {
    if (currentSubscription.value == null || selectedPackage.value == null) {
      return false;
    }
    return selectedPackage.value!.price >
        currentSubscription.value!.package.price;
  }

  // التحقق من إمكانية التخفيض
  bool canDowngradePackage() {
    if (currentSubscription.value == null || selectedPackage.value == null) {
      return false;
    }
    return selectedPackage.value!.price <
        currentSubscription.value!.package.price;
  }

  // الحصول على نص زر الاشتراك
  String getSubscriptionButtonText() {
    if (currentSubscription.value == null) {
      return 'بدء الاشتراك';
    }

    if (canUpgradePackage()) {
      return 'ترقية الاشتراك';
    } else if (canDowngradePackage()) {
      return 'تغيير الاشتراك';
    } else {
      return 'تجديد الاشتراك';
    }
  }

  // إظهار تحذير انتهاء الاشتراك
  void showExpirationWarning() {
    if (!isSubscriptionExpiringSoon) return;

    AppUtils.showWarningSnackbar('تحذير انتهاء الاشتراك',
        'اشتراكك سينتهي خلال $daysRemaining أيام. جدد الآن لتجنب انقطاع الخدمة');
  }

  // تحديث جميع البيانات
  Future<void> refreshAllData({int? doctorId}) async {
    await Future.wait([
      loadSubscriptionPackages(),
      loadAllFeatures(),
      if (_authController.isDoctor) loadDoctorSubscriptions(doctorId: doctorId),
      if (_authController.isDoctor) loadSubscriptionStats(),
    ]);
  }

  // إعادة تعيين الاختيارات
  void resetSelections() {
    selectedPackage.value = null;
    isYearlySelected.value = false;
  }

  // الحصول على إحصائيات الاستخدام
  Map<String, dynamic> getUsageStats() {
    if (currentSubscription.value == null) return {};

    final package = currentSubscription.value!.package;

    return {
      'maxDailyAppointments': package.maxDailyAppointments,
      'maxWeeklyDays': package.maxWeeklyDays,
      'maxActiveOffers': package.maxActiveOffers,
      'currentDailyAppointments': 0, // TODO: جلب من الإحصائيات الفعلية
      'currentWeeklyDays': 0, // TODO: جلب من الإحصائيات الفعلية
      'currentActiveOffers': 0, // TODO: جلب من الإحصائيات الفعلية
    };
  }

  // التحقق من تجاوز الحدود
  bool isLimitExceeded(String limitType) {
    final stats = getUsageStats();

    switch (limitType) {
      case 'dailyAppointments':
        return (stats['currentDailyAppointments'] ?? 0) >=
            (stats['maxDailyAppointments'] ?? 0);
      case 'weeklyDays':
        return (stats['currentWeeklyDays'] ?? 0) >=
            (stats['maxWeeklyDays'] ?? 0);
      case 'activeOffers':
        return (stats['currentActiveOffers'] ?? 0) >=
            (stats['maxActiveOffers'] ?? 0);
      default:
        return false;
    }
  }
}
