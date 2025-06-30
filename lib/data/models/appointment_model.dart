import 'user_model.dart';
import 'doctor_model.dart';

class AppointmentModel {
  final int id;
  final UserModel user;
  final DoctorModel doctor;
  final DateTime appointmentDate;
  final int status;
  final double paymentAmount;
  final int paymentStatus;
  final String? notes;

  AppointmentModel({
    required this.id,
    required this.user,
    required this.doctor,
    required this.appointmentDate,
    required this.status,
    required this.paymentAmount,
    required this.paymentStatus,
    this.notes,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? 0,
      user: UserModel.fromJson(json['user'] ?? {}),
      doctor: DoctorModel.fromJson(json['doctor'] ?? {}),
      appointmentDate:
          DateTime.tryParse(json['appointmentDate'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 0,
      paymentAmount: (json['paymentAmount'] ?? 0).toDouble(),
      paymentStatus: json['paymentStatus'] ?? 0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'doctor': doctor.toJson(),
      'appointmentDate': appointmentDate.toIso8601String(),
      'status': status,
      'paymentAmount': paymentAmount,
      'paymentStatus': paymentStatus,
      'notes': notes,
    };
  }

  AppointmentModel copyWith({
    int? id,
    UserModel? user,
    DoctorModel? doctor,
    DateTime? appointmentDate,
    int? status,
    double? paymentAmount,
    int? paymentStatus,
    String? notes,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      user: user ?? this.user,
      doctor: doctor ?? this.doctor,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      status: status ?? this.status,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
    );
  }

  // Helper getters للحالات
  bool get isPending => status == 0;
  bool get isApproved => status == 1;
  bool get isRejected => status == 2;
  bool get isCompleted => status == 3;

  bool get isUnpaid => paymentStatus == 0;
  bool get isPaidOnline => paymentStatus == 1;
  bool get isPaidInClinic => paymentStatus == 2;

  // Helper methods للتواريخ
  bool get isToday {
    final now = DateTime.now();
    return appointmentDate.year == now.year &&
        appointmentDate.month == now.month &&
        appointmentDate.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return appointmentDate.year == tomorrow.year &&
        appointmentDate.month == tomorrow.month &&
        appointmentDate.day == tomorrow.day;
  }

  bool get isPast => appointmentDate.isBefore(DateTime.now());
  bool get isUpcoming => appointmentDate.isAfter(DateTime.now());

  // حساب الوقت المتبقي للموعد
  Duration get timeUntilAppointment {
    final now = DateTime.now();
    if (appointmentDate.isAfter(now)) {
      return appointmentDate.difference(now);
    }
    return Duration.zero;
  }

  String get timeUntilText {
    if (isPast) return 'انتهى';

    final duration = timeUntilAppointment;
    if (duration.inDays > 0) {
      return 'خلال ${duration.inDays} ${duration.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (duration.inHours > 0) {
      return 'خلال ${duration.inHours} ${duration.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (duration.inMinutes > 0) {
      return 'خلال ${duration.inMinutes} ${duration.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  @override
  String toString() {
    return 'AppointmentModel(id: $id, doctor: ${doctor.name}, date: $appointmentDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppointmentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// نموذج إنشاء موعد
class CreateAppointmentRequest {
  final int doctorId;
  final DateTime appointmentDate;
  final String? notes;

  CreateAppointmentRequest({
    required this.doctorId,
    required this.appointmentDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'appointmentDate': appointmentDate.toIso8601String(),
      'notes': notes,
    };
  }
}

// نموذج فلترة المواعيد
class AppointmentFilterRequest {
  final int? id;
  final String? userId;
  final String? userFullName;
  final int? doctorId;
  final String? doctorFullName;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? status;

  AppointmentFilterRequest({
    this.id,
    this.userId,
    this.userFullName,
    this.doctorId,
    this.doctorFullName,
    this.fromDate,
    this.toDate,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userFullName': userFullName,
      'doctorId': doctorId,
      'doctorFullName': doctorFullName,
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
      'status': status,
    };
  }

  // تحويل إلى Query Parameters للـ GET request
  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    if (id != null) params['Id'] = id.toString();
    if (userId != null) params['UserId'] = userId!;
    if (userFullName != null && userFullName!.isNotEmpty) {
      params['UserFullName'] = userFullName!;
    }
    if (doctorId != null) params['DoctorId'] = doctorId.toString();
    if (doctorFullName != null && doctorFullName!.isNotEmpty) {
      params['DoctorFullName'] = doctorFullName!;
    }
    if (fromDate != null) {
      params['FromDate'] = fromDate!.toIso8601String().split('T')[0];
    }
    if (toDate != null) {
      params['ToDate'] = toDate!.toIso8601String().split('T')[0];
    }
    if (status != null) params['Status'] = status.toString();

    return params;
  }

  AppointmentFilterRequest copyWith({
    int? id,
    String? userId,
    String? userFullName,
    int? doctorId,
    String? doctorFullName,
    DateTime? fromDate,
    DateTime? toDate,
    int? status,
  }) {
    return AppointmentFilterRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userFullName: userFullName ?? this.userFullName,
      doctorId: doctorId ?? this.doctorId,
      doctorFullName: doctorFullName ?? this.doctorFullName,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      status: status ?? this.status,
    );
  }
}
