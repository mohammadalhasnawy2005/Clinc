import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/appointment_service.dart';
import '../data/models/appointment_model.dart';
import '../data/models/doctor_model.dart';
import '../core/utils/app_utils.dart';
import 'auth_controller.dart';

class AppointmentController extends GetxController {
  // Loading States
  final RxBool isLoading = false.obs;
  final RxBool isCreatingAppointment = false.obs;
  final RxBool isUpdatingStatus = false.obs;
  final RxBool isLoadingAppointments = false.obs;

  // Data Lists
  final RxList<AppointmentModel> allAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> myAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> doctorAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> pendingAppointments = <AppointmentModel>[].obs;
  final RxList<AppointmentModel> upcomingAppointments =
      <AppointmentModel>[].obs;
  final RxList<AppointmentModel> completedAppointments =
      <AppointmentModel>[].obs;

  // Current Selection
  final Rx<AppointmentModel?> selectedAppointment = Rx<AppointmentModel?>(null);
  final Rx<DoctorModel?> selectedDoctor = Rx<DoctorModel?>(null);
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasMoreData = true.obs;

  // Filters
  final RxInt statusFilter = (-1).obs; // -1 = all, 0-3 = specific status
  final Rx<DateTime?> fromDateFilter = Rx<DateTime?>(null);
  final Rx<DateTime?> toDateFilter = Rx<DateTime?>(null);

  // Statistics
  final RxMap<String, int> appointmentStats = <String, int>{}.obs;

  // Booking Form
  final GlobalKey<FormState> bookingFormKey = GlobalKey<FormState>();
  final TextEditingController notesController = TextEditingController();

  // Get AuthController
  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }

  // تهيئة البيانات
  Future<void> _initializeData() async {
    if (_authController.isLoggedIn) {
      if (_authController.isPatient) {
        await loadMyAppointments();
      } else if (_authController.isDoctor) {
        await loadDoctorAppointments();
        await loadAppointmentStats();
      }
    }
  }

  // تحميل مواعيد المريض
  Future<void> loadMyAppointments({bool refresh = false}) async {
    try {
      isLoadingAppointments.value = true;

      final appointments = await AppointmentService.getMyAppointments(
        status: statusFilter.value == -1 ? null : statusFilter.value,
      );

      myAppointments.assignAll(appointments);

      // تصنيف المواعيد
      _categorizeAppointments(appointments);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل مواعيدك');
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  // تحميل مواعيد الطبيب
  Future<void> loadDoctorAppointments({
    int? doctorId,
    bool refresh = false,
  }) async {
    try {
      isLoadingAppointments.value = true;

      final appointments = await AppointmentService.getDoctorAppointments(
        doctorId: doctorId,
        status: statusFilter.value == -1 ? null : statusFilter.value,
        fromDate: fromDateFilter.value,
        toDate: toDateFilter.value,
      );

      doctorAppointments.assignAll(appointments);

      // تحميل طلبات الحجز المعلقة
      await loadPendingAppointments(doctorId: doctorId);

      // تصنيف المواعيد
      _categorizeAppointments(appointments);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل مواعيد العيادة');
    } finally {
      isLoadingAppointments.value = false;
    }
  }

  // تحميل طلبات الحجز المعلقة
  Future<void> loadPendingAppointments({int? doctorId}) async {
    try {
      final pending = await AppointmentService.getPendingAppointments(
        doctorId: doctorId,
      );
      pendingAppointments.assignAll(pending);
    } catch (e) {
      AppUtils.logError('فشل في تحميل الطلبات المعلقة', e);
    }
  }

  // تحميل المواعيد القادمة
  Future<void> loadUpcomingAppointments() async {
    try {
      final upcoming = await AppointmentService.getUpcomingAppointments();
      upcomingAppointments.assignAll(upcoming);
    } catch (e) {
      AppUtils.logError('فشل في تحميل المواعيد القادمة', e);
    }
  }

  // تحميل مواعيد اليوم
  Future<List<AppointmentModel>> getTodayAppointments({int? doctorId}) async {
    try {
      return await AppointmentService.getTodayAppointments(doctorId: doctorId);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل مواعيد اليوم');
      return [];
    }
  }

  // إنشاء موعد جديد
  Future<void> createAppointment({
    required int doctorId,
    required DateTime appointmentDate,
    String? notes,
  }) async {
    try {
      isCreatingAppointment.value = true;

      // التحقق من توفر الموعد
      final isAvailable = await AppointmentService.isAppointmentAvailable(
        doctorId,
        appointmentDate,
      );

      if (!isAvailable) {
        AppUtils.showWarningSnackbar(
            'موعد غير متاح', 'هذا التوقيت غير متاح، يرجى اختيار وقت آخر');
        return;
      }

      final request = CreateAppointmentRequest(
        doctorId: doctorId,
        appointmentDate: appointmentDate,
        notes: notes,
      );

      final response = await AppointmentService.createAppointment(request);

      if (response.isSuccess) {
        AppUtils.showSuccessSnackbar('تم حجز الموعد',
            'تم إرسال طلب الحجز للطبيب، ستحصل على رد خلال 48 ساعة');

        // تحديث البيانات
        await loadMyAppointments(refresh: true);

        // مسح النموذج
        _clearBookingForm();

        Get.back(); // الرجوع للصفحة السابقة
      } else {
        AppUtils.showErrorSnackbar('فشل الحجز', response.message);
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في الحجز', e.toString());
    } finally {
      isCreatingAppointment.value = false;
    }
  }

  // تغيير حالة الموعد (للطبيب)
  Future<void> toggleAppointmentStatus(int appointmentId) async {
    try {
      isUpdatingStatus.value = true;

      final response =
          await AppointmentService.toggleAppointmentStatus(appointmentId);

      if (response.isSuccess) {
        AppUtils.showSuccessSnackbar(
            'تم التحديث', 'تم تحديث حالة الموعد بنجاح');

        // تحديث البيانات
        await loadDoctorAppointments(refresh: true);
      } else {
        AppUtils.showErrorSnackbar('فشل التحديث', response.message);
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في التحديث', e.toString());
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  // إكمال الموعد (للطبيب)
  Future<void> completeAppointment(int appointmentId) async {
    try {
      isUpdatingStatus.value = true;

      final response =
          await AppointmentService.completeAppointment(appointmentId);

      if (response.isSuccess) {
        AppUtils.showSuccessSnackbar(
            'تم الإكمال', 'تم إكمال الموعد ونقله للأرشيف');

        // تحديث البيانات
        await loadDoctorAppointments(refresh: true);
        await loadAppointmentStats();
      } else {
        AppUtils.showErrorSnackbar('فشل الإكمال', response.message);
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في الإكمال', e.toString());
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  // تحميل إحصائيات المواعيد
  Future<void> loadAppointmentStats({int? doctorId}) async {
    try {
      final stats = await AppointmentService.getAppointmentStats(
        doctorId: doctorId,
      );
      appointmentStats.assignAll(stats);
    } catch (e) {
      AppUtils.logError('فشل في تحميل الإحصائيات', e);
    }
  }

  // تصنيف المواعيد حسب الحالة
  void _categorizeAppointments(List<AppointmentModel> appointments) {
    final upcoming = <AppointmentModel>[];
    final completed = <AppointmentModel>[];

    for (final appointment in appointments) {
      if (appointment.isCompleted) {
        completed.add(appointment);
      } else if (appointment.isApproved && appointment.isUpcoming) {
        upcoming.add(appointment);
      }
    }

    upcomingAppointments.assignAll(upcoming);
    completedAppointments.assignAll(completed);
  }

  // تطبيق فلتر الحالة
  void applyStatusFilter(int status) {
    statusFilter.value = status;
    if (_authController.isPatient) {
      loadMyAppointments(refresh: true);
    } else if (_authController.isDoctor) {
      loadDoctorAppointments(refresh: true);
    }
  }

  // تطبيق فلتر التاريخ
  void applyDateFilter(DateTime? fromDate, DateTime? toDate) {
    fromDateFilter.value = fromDate;
    toDateFilter.value = toDate;
    if (_authController.isDoctor) {
      loadDoctorAppointments(refresh: true);
    }
  }

  // مسح جميع الفلاتر
  void clearFilters() {
    statusFilter.value = -1;
    fromDateFilter.value = null;
    toDateFilter.value = null;
    if (_authController.isPatient) {
      loadMyAppointments(refresh: true);
    } else if (_authController.isDoctor) {
      loadDoctorAppointments(refresh: true);
    }
  }

  // اختيار موعد
  void selectAppointment(AppointmentModel appointment) {
    selectedAppointment.value = appointment;
  }

  // اختيار طبيب للحجز
  void selectDoctorForBooking(DoctorModel doctor) {
    selectedDoctor.value = doctor;
  }

  // اختيار تاريخ للحجز
  void selectDateForBooking(DateTime date) {
    selectedDate.value = date;
  }

  // التحقق من إمكانية الحجز
  bool canBookAppointment() {
    return selectedDoctor.value != null && selectedDate.value != null;
  }

  // الحصول على عدد المواعيد حسب الحالة
  int getAppointmentCountByStatus(int status) {
    if (_authController.isPatient) {
      return myAppointments.where((apt) => apt.status == status).length;
    } else if (_authController.isDoctor) {
      return doctorAppointments.where((apt) => apt.status == status).length;
    }
    return 0;
  }

  // الحصول على المواعيد حسب الحالة
  List<AppointmentModel> getAppointmentsByStatus(int status) {
    if (_authController.isPatient) {
      return myAppointments.where((apt) => apt.status == status).toList();
    } else if (_authController.isDoctor) {
      return doctorAppointments.where((apt) => apt.status == status).toList();
    }
    return [];
  }

  // حساب الوقت المتبقي للموعد
  String getTimeUntilAppointment(AppointmentModel appointment) {
    return appointment.timeUntilText;
  }

  // التحقق من قرب انتهاء فترة الموافقة (48 ساعة)
  bool isApprovalTimeExpiring(AppointmentModel appointment) {
    if (!appointment.isPending) return false;

    final hoursSinceCreation =
        DateTime.now().difference(appointment.appointmentDate).inHours;

    return hoursSinceCreation >= 36; // تحذير قبل 12 ساعة من انتهاء المهلة
  }

  // مسح نموذج الحجز
  void _clearBookingForm() {
    notesController.clear();
    selectedDoctor.value = null;
    selectedDate.value = null;
  }

  // تحديث جميع البيانات
  Future<void> refreshAllData() async {
    if (_authController.isPatient) {
      await loadMyAppointments(refresh: true);
    } else if (_authController.isDoctor) {
      await Future.wait([
        loadDoctorAppointments(refresh: true),
        loadAppointmentStats(),
      ]);
    }
  }

  // إظهار تفاصيل الموعد
  void showAppointmentDetails(AppointmentModel appointment) {
    selectedAppointment.value = appointment;
    Get.toNamed('/appointment-details');
  }

  // إظهار حوار تأكيد إكمال الموعد
  void showCompleteAppointmentDialog(AppointmentModel appointment) {
    Get.dialog(
      AlertDialog(
        title: const Text('إكمال الموعد'),
        content: Text('هل أنت متأكد من إكمال موعد ${appointment.user.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              completeAppointment(appointment.id);
            },
            child: const Text('إكمال'),
          ),
        ],
      ),
    );
  }

  // إظهار حوار تغيير حالة الموعد
  void showToggleStatusDialog(AppointmentModel appointment) {
    final String actionText = appointment.isPending ? 'موافقة' : 'تغيير حالة';

    Get.dialog(
      AlertDialog(
        title: Text('$actionText الموعد'),
        content: Text('هل تريد $actionText موعد ${appointment.user.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              toggleAppointmentStatus(appointment.id);
            },
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}
