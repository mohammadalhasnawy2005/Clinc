import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/appointment_service.dart';
import '../data/models/appointment_model.dart';
import '../data/models/doctor_model.dart';
import '../core/utils/app_utils.dart';
import 'auth_controller.dart';

class AppointmentController extends GetxController {
  static AppointmentController get instance => Get.find();

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
  final RxInt statusFilter = (-1).obs;
  final Rx<DateTime?> fromDateFilter = Rx<DateTime?>(null);
  final Rx<DateTime?> toDateFilter = Rx<DateTime?>(null);

  // Statistics
  final RxMap<String, int> appointmentStats = <String, int>{}.obs;

  // Booking Form
  final GlobalKey<FormState> bookingFormKey = GlobalKey<FormState>();
  final TextEditingController notesController = TextEditingController();

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

  Future<void> _initializeData() async {
    try {
      // التأكد من وجود AuthController
      if (Get.isRegistered<AuthController>()) {
        final authController = AuthController.instance;

        if (authController.isLoggedIn) {
          if (authController.isPatient) {
            await loadMyAppointments();
          } else if (authController.isDoctor) {
            await loadDoctorAppointments();
            await loadAppointmentStats();
          }
        }
      }
    } catch (e) {
      print('Error initializing appointment data: $e');
    }
  }

  Future<void> loadMyAppointments({bool refresh = false}) async {
    try {
      isLoadingAppointments.value = true;

      final appointments = await AppointmentService.getMyAppointments(
        status: statusFilter.value == -1 ? null : statusFilter.value,
      );

      myAppointments.assignAll(appointments);
      _categorizeAppointments(appointments);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل مواعيدك');
    } finally {
      isLoadingAppointments.value = false;
    }
  }

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
      await loadPendingAppointments(doctorId: doctorId);
      _categorizeAppointments(appointments);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل مواعيد العيادة');
    } finally {
      isLoadingAppointments.value = false;
    }
  }

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

  Future<void> loadUpcomingAppointments() async {
    try {
      final upcoming = await AppointmentService.getUpcomingAppointments();
      upcomingAppointments.assignAll(upcoming);
    } catch (e) {
      AppUtils.logError('فشل في تحميل المواعيد القادمة', e);
    }
  }

  Future<List<AppointmentModel>> getTodayAppointments({int? doctorId}) async {
    try {
      return await AppointmentService.getTodayAppointments(doctorId: doctorId);
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ', 'فشل في تحميل مواعيد اليوم');
      return [];
    }
  }

  Future<void> createAppointment({
    required int doctorId,
    required DateTime appointmentDate,
    String? notes,
  }) async {
    try {
      isCreatingAppointment.value = true;

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

        await loadMyAppointments(refresh: true);
        _clearBookingForm();
        Get.back();
      } else {
        AppUtils.showErrorSnackbar('فشل الحجز', response.message);
      }
    } catch (e) {
      AppUtils.showErrorSnackbar('خطأ في الحجز', e.toString());
    } finally {
      isCreatingAppointment.value = false;
    }
  }

  Future<void> toggleAppointmentStatus(int appointmentId) async {
    try {
      isUpdatingStatus.value = true;

      final response =
          await AppointmentService.toggleAppointmentStatus(appointmentId);

      if (response.isSuccess) {
        AppUtils.showSuccessSnackbar(
            'تم التحديث', 'تم تحديث حالة الموعد بنجاح');
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

  Future<void> completeAppointment(int appointmentId) async {
    try {
      isUpdatingStatus.value = true;

      final response =
          await AppointmentService.completeAppointment(appointmentId);

      if (response.isSuccess) {
        AppUtils.showSuccessSnackbar(
            'تم الإكمال', 'تم إكمال الموعد ونقله للأرشيف');
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

  void applyStatusFilter(int status) {
    statusFilter.value = status;
    if (Get.isRegistered<AuthController>()) {
      final authController = AuthController.instance;
      if (authController.isPatient) {
        loadMyAppointments(refresh: true);
      } else if (authController.isDoctor) {
        loadDoctorAppointments(refresh: true);
      }
    }
  }

  void applyDateFilter(DateTime? fromDate, DateTime? toDate) {
    fromDateFilter.value = fromDate;
    toDateFilter.value = toDate;
    if (Get.isRegistered<AuthController>()) {
      final authController = AuthController.instance;
      if (authController.isDoctor) {
        loadDoctorAppointments(refresh: true);
      }
    }
  }

  void clearFilters() {
    statusFilter.value = -1;
    fromDateFilter.value = null;
    toDateFilter.value = null;
    if (Get.isRegistered<AuthController>()) {
      final authController = AuthController.instance;
      if (authController.isPatient) {
        loadMyAppointments(refresh: true);
      } else if (authController.isDoctor) {
        loadDoctorAppointments(refresh: true);
      }
    }
  }

  void selectAppointment(AppointmentModel appointment) {
    selectedAppointment.value = appointment;
  }

  void selectDoctorForBooking(DoctorModel doctor) {
    selectedDoctor.value = doctor;
  }

  void selectDateForBooking(DateTime date) {
    selectedDate.value = date;
  }

  bool canBookAppointment() {
    return selectedDoctor.value != null && selectedDate.value != null;
  }

  int getAppointmentCountByStatus(int status) {
    if (Get.isRegistered<AuthController>()) {
      final authController = AuthController.instance;
      if (authController.isPatient) {
        return myAppointments.where((apt) => apt.status == status).length;
      } else if (authController.isDoctor) {
        return doctorAppointments.where((apt) => apt.status == status).length;
      }
    }
    return 0;
  }

  List<AppointmentModel> getAppointmentsByStatus(int status) {
    if (Get.isRegistered<AuthController>()) {
      final authController = AuthController.instance;
      if (authController.isPatient) {
        return myAppointments.where((apt) => apt.status == status).toList();
      } else if (authController.isDoctor) {
        return doctorAppointments.where((apt) => apt.status == status).toList();
      }
    }
    return [];
  }

  String getTimeUntilAppointment(AppointmentModel appointment) {
    return appointment.timeUntilText;
  }

  bool isApprovalTimeExpiring(AppointmentModel appointment) {
    if (!appointment.isPending) return false;

    final hoursSinceCreation =
        DateTime.now().difference(appointment.appointmentDate).inHours;
    return hoursSinceCreation >= 36;
  }

  void _clearBookingForm() {
    notesController.clear();
    selectedDoctor.value = null;
    selectedDate.value = null;
  }

  Future<void> refreshAllData() async {
    if (Get.isRegistered<AuthController>()) {
      final authController = AuthController.instance;
      if (authController.isPatient) {
        await loadMyAppointments(refresh: true);
      } else if (authController.isDoctor) {
        await Future.wait([
          loadDoctorAppointments(refresh: true),
          loadAppointmentStats(),
        ]);
      }
    }
  }

  void showAppointmentDetails(AppointmentModel appointment) {
    selectedAppointment.value = appointment;
    Get.toNamed('/appointment-details');
  }

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
