import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../data/services/doctor_service.dart';
import '../data/services/general_service.dart';
import '../data/models/doctor_model.dart';
import '../data/models/specialization_model.dart';
import '../core/utils/app_utils.dart';
import '../core/constants/app_constants.dart';
import 'auth_controller.dart';

class DoctorController extends GetxController {
  // Loading States
  final RxBool isLoading = false.obs;
  final RxBool isCreatingDoctor = false.obs;
  final RxBool isLoadingDoctors = false.obs;
  final RxBool isLoadingAvailability = false.obs;

  // Data Lists
  final RxList<DoctorModel> doctors = <DoctorModel>[].obs;
  final RxList<DoctorModel> filteredDoctors = <DoctorModel>[].obs;
  final RxList<SpecializationModel> specializations =
      <SpecializationModel>[].obs;
  final RxList<DayModel> days = <DayModel>[].obs;

  // Current Selection
  final Rx<DoctorModel?> selectedDoctor = Rx<DoctorModel?>(null);
  final Rx<SpecializationModel?> selectedSpecialization =
      Rx<SpecializationModel?>(null);
  final RxList<DayAvailabilityModel> doctorAvailability =
      <DayAvailabilityModel>[].obs;

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMoreData = true.obs;

  // Search & Filter
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxInt selectedSpecializationId = 0.obs;
  final RxInt selectedProvinceId = 0.obs;

  // Create Doctor Form
  final GlobalKey<FormState> createDoctorFormKey = GlobalKey<FormState>();
  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController doctorNormalizedNameController =
      TextEditingController();
  final TextEditingController doctorDescriptionController =
      TextEditingController();
  final TextEditingController doctorPhoneController = TextEditingController();
  final TextEditingController doctorLocationController =
      TextEditingController();
  final TextEditingController doctorBirthDayController =
      TextEditingController();
  final RxString doctorImagePath = ''.obs;
  final RxInt doctorSpecializationId = 0.obs;
  final RxInt doctorProvinceId = 0.obs;

  // Get AuthController
  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _setupSearchListener();
  }

  @override
  void onClose() {
    searchController.dispose();
    doctorNameController.dispose();
    doctorNormalizedNameController.dispose();
    doctorDescriptionController.dispose();
    doctorPhoneController.dispose();
    doctorLocationController.dispose();
    doctorBirthDayController.dispose();
    super.onClose();
  }

  // تهيئة البيانات الأساسية
  Future<void> _initializeData() async {
    await loadSpecializations();
    await loadDays();
    await loadDoctors();
  }

  // إعداد مستمع البحث
  void _setupSearchListener() {
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _performSearch();
    });
  }

  // تحميل التخصصات
  Future<void> loadSpecializations() async {
    try {
      final specs = await GeneralService.getSpecializations();
      specializations.assignAll(specs);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل التخصصات');
    }
  }

  // تحميل الأيام
  Future<void> loadDays() async {
    try {
      final daysList = await GeneralService.getDays();
      days.assignAll(daysList);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل الأيام');
    }
  }

  // تحميل قائمة الأطباء
  Future<void> loadDoctors({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      doctors.clear();
    }

    if (!hasMoreData.value) return;

    try {
      isLoadingDoctors.value = true;

      final response = await DoctorService.getDoctors(
        page: currentPage.value,
        pageSize: AppConstants.doctorsPageSize,
        specializationId: selectedSpecializationId.value == 0
            ? null
            : selectedSpecializationId.value,
        iraqiProvince:
            selectedProvinceId.value == 0 ? null : selectedProvinceId.value,
        name: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (refresh) {
        doctors.assignAll(response.items);
      } else {
        doctors.addAll(response.items);
      }

      totalPages.value = response.totalPages;
      hasMoreData.value = currentPage.value < response.totalPages;
      currentPage.value++;

      _applyFilters();
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل الأطباء');
    } finally {
      isLoadingDoctors.value = false;
    }
  }

  // تحميل المزيد من الأطباء
  Future<void> loadMoreDoctors() async {
    if (!hasMoreData.value || isLoadingDoctors.value) return;
    await loadDoctors();
  }

  // البحث عن الأطباء
  void _performSearch() {
    if (searchQuery.value.length >= 2 || searchQuery.value.isEmpty) {
      _debounceSearch();
    }
  }

  // تأخير البحث لتحسين الأداء
  void _debounceSearch() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchQuery.value == searchController.text) {
        loadDoctors(refresh: true);
      }
    });
  }

  // تطبيق الفلاتر
  void _applyFilters() {
    var filtered = doctors.toList();

    // فلترة حسب التخصص
    if (selectedSpecializationId.value != 0) {
      filtered = filtered
          .where((doctor) =>
              doctor.specialization.id == selectedSpecializationId.value)
          .toList();
    }

    // فلترة حسب المحافظة
    if (selectedProvinceId.value != 0) {
      filtered = filtered
          .where((doctor) => doctor.iraqiProvince == selectedProvinceId.value)
          .toList();
    }

    // فلترة حسب البحث
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where((doctor) => doctor.name
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    filteredDoctors.assignAll(filtered);
  }

  // تطبيق فلتر التخصص
  void applySpecializationFilter(int? specializationId) {
    selectedSpecializationId.value = specializationId ?? 0;
    loadDoctors(refresh: true);
  }

  // تطبيق فلتر المحافظة
  void applyProvinceFilter(int? provinceId) {
    selectedProvinceId.value = provinceId ?? 0;
    loadDoctors(refresh: true);
  }

  // مسح جميع الفلاتر
  void clearFilters() {
    selectedSpecializationId.value = 0;
    selectedProvinceId.value = 0;
    searchController.clear();
    selectedSpecialization.value = null;
    loadDoctors(refresh: true);
  }

  // اختيار طبيب
  void selectDoctor(DoctorModel doctor) {
    selectedDoctor.value = doctor;
    loadDoctorAvailability(doctor.id);
  }

  // تحميل جدول أوقات الطبيب
  Future<void> loadDoctorAvailability(int doctorId) async {
    try {
      isLoadingAvailability.value = true;

      final response = await DoctorService.getDoctorAvailability(doctorId);

      if (response.isSuccess && response.data != null) {
        doctorAvailability.assignAll(response.data!);
      } else {
        doctorAvailability.clear();
      }
    } catch (e) {
      doctorAvailability.clear();
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل جدول الطبيب');
    } finally {
      isLoadingAvailability.value = false;
    }
  }

  // إنشاء طبيب/عيادة جديدة
  Future<void> createDoctor() async {
    if (!createDoctorFormKey.currentState!.validate()) return;
    if (doctorImagePath.value.isEmpty) {
      AppUtils.showErrorSnackbar('خطأ', 'يرجى اختيار صورة للعيادة');
      return;
    }

    try {
      isCreatingDoctor.value = true;

      final request = CreateDoctorRequest(
        name: doctorNameController.text.trim(),
        normalizedName: doctorNormalizedNameController.text.trim(),
        specializationId: doctorSpecializationId.value,
        description: doctorDescriptionController.text.trim(),
        iraqiProvince: doctorProvinceId.value,
        birthDay: doctorBirthDayController.text.trim(),
        phoneNumber: doctorPhoneController.text.trim(),
        location: doctorLocationController.text.trim(),
      );

      final response = await DoctorService.createDoctor(
        request,
        doctorImagePath.value,
      );

      if (response.isSuccess) {
        // تحديث نوع المستخدم إلى طبيب
        _authController.updateUserType(AppConstants.userTypeDoctor);

        AppUtils.showSuccessSnackbar(
            'نجح إنشاء العيادة', 'تم إنشاء عيادتك بنجاح');

        _clearCreateDoctorForm();
        Get.offAllNamed('/doctor-dashboard');
      } else {
        AppUtils.showErrorSnackbar('فشل إنشاء العيادة', response.message);
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في إنشاء العيادة', e.toString());
    } finally {
      isCreatingDoctor.value = false;
    }
  }

  // تحديد جدول أوقات العمل
  Future<void> setDoctorAvailability(
    int doctorId,
    List<DayAvailabilityModel> availability,
  ) async {
    try {
      isLoading.value = true;

      final request = DoctorAvailabilityModel(
        doctorId: doctorId,
        days: availability,
      );

      final response = await DoctorService.setDoctorAvailability(request);

      if (response.isSuccess) {
        AppUtils.showSuccessSnackbar(
            'تم التحديث', 'تم تحديد أوقات العمل بنجاح');

        // إعادة تحميل الجدول
        await loadDoctorAvailability(doctorId);
      } else {
        AppUtils.showErrorSnackbar('فشل التحديث', response.message);
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في التحديث', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // اختيار صورة العيادة
  Future<void> pickDoctorImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        doctorImagePath.value = image.path;
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في اختيار الصورة');
    }
  }

  // جلب الأطباء الأعلى تقييماً
  Future<List<DoctorModel>> getTopDoctors() async {
    try {
      return await DoctorService.getTopDoctors();
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل أفضل الأطباء');
      return [];
    }
  }

  // جلب الأطباء القريبين
  Future<List<DoctorModel>> getNearbyDoctors(int provinceId) async {
    try {
      return await DoctorService.getNearbyDoctors(provinceId);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل الأطباء القريبين');
      return [];
    }
  }

  // التحقق من توفر يوم العمل
  bool isDayAvailable(int dayId) {
    return doctorAvailability
        .any((availability) => availability.dayId == dayId);
  }

  // الحصول على أوقات العمل ليوم محدد
  DayAvailabilityModel? getDayAvailability(int dayId) {
    try {
      return doctorAvailability
          .firstWhere((availability) => availability.dayId == dayId);
    } catch (e) {
      return null;
    }
  }

  // مسح نموذج إنشاء الطبيب
  void _clearCreateDoctorForm() {
    doctorNameController.clear();
    doctorNormalizedNameController.clear();
    doctorDescriptionController.clear();
    doctorPhoneController.clear();
    doctorLocationController.clear();
    doctorBirthDayController.clear();
    doctorImagePath.value = '';
    doctorSpecializationId.value = 0;
    doctorProvinceId.value = 0;
  }

  // تحديث البيانات
  Future<void> refreshData() async {
    await Future.wait([
      loadSpecializations(),
      loadDays(),
      loadDoctors(refresh: true),
    ]);
  }

  // دوال التحقق من صحة البيانات
  String? validateDoctorName(String? value) => AppUtils.validateName(value);
  String? validateDoctorPhone(String? value) => AppUtils.validatePhone(value);
  String? validateRequired(String? value, String fieldName) =>
      AppUtils.validateRequired(value, fieldName);
}
