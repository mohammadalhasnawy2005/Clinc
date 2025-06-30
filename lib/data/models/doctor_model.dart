import 'specialization_model.dart';

class DoctorModel {
  final int id;
  final String name;
  final String normalizedName;
  final SpecializationModel specialization;
  final String description;
  final int subscriptionRank;
  final int iraqiProvince;
  final String iraqiProvinceName;
  final String iraqiProvinceNormalizedName;
  final String imageName;
  final String birthDay;
  final String phoneNumber;
  final String location;

  DoctorModel({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.specialization,
    required this.description,
    required this.subscriptionRank,
    required this.iraqiProvince,
    required this.iraqiProvinceName,
    required this.iraqiProvinceNormalizedName,
    required this.imageName,
    required this.birthDay,
    required this.phoneNumber,
    required this.location,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      normalizedName: json['normalizedName'] ?? '',
      specialization: SpecializationModel.fromJson(
        json['specialization'] ?? {},
      ),
      description: json['description'] ?? '',
      subscriptionRank: json['subscriptionRank'] ?? 0,
      iraqiProvince: json['iraqiProvince'] ?? 0,
      iraqiProvinceName: json['iraqiProvinceName'] ?? '',
      iraqiProvinceNormalizedName: json['iraqiProvinceNormalizedName'] ?? '',
      imageName: json['imageName'] ?? '',
      birthDay: json['birthDay'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'normalizedName': normalizedName,
      'specialization': specialization.toJson(),
      'description': description,
      'subscriptionRank': subscriptionRank,
      'iraqiProvince': iraqiProvince,
      'iraqiProvinceName': iraqiProvinceName,
      'iraqiProvinceNormalizedName': iraqiProvinceNormalizedName,
      'imageName': imageName,
      'birthDay': birthDay,
      'phoneNumber': phoneNumber,
      'location': location,
    };
  }

  DoctorModel copyWith({
    int? id,
    String? name,
    String? normalizedName,
    SpecializationModel? specialization,
    String? description,
    int? subscriptionRank,
    int? iraqiProvince,
    String? iraqiProvinceName,
    String? iraqiProvinceNormalizedName,
    String? imageName,
    String? birthDay,
    String? phoneNumber,
    String? location,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      specialization: specialization ?? this.specialization,
      description: description ?? this.description,
      subscriptionRank: subscriptionRank ?? this.subscriptionRank,
      iraqiProvince: iraqiProvince ?? this.iraqiProvince,
      iraqiProvinceName: iraqiProvinceName ?? this.iraqiProvinceName,
      iraqiProvinceNormalizedName:
          iraqiProvinceNormalizedName ?? this.iraqiProvinceNormalizedName,
      imageName: imageName ?? this.imageName,
      birthDay: birthDay ?? this.birthDay,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
    );
  }

  @override
  String toString() {
    return 'DoctorModel(id: $id, name: $name, specialization: ${specialization.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// نموذج إنشاء طبيب/عيادة
class CreateDoctorRequest {
  final String name;
  final String normalizedName;
  final int specializationId;
  final String description;
  final int iraqiProvince;
  final String birthDay;
  final String phoneNumber;
  final String location;

  CreateDoctorRequest({
    required this.name,
    required this.normalizedName,
    required this.specializationId,
    required this.description,
    required this.iraqiProvince,
    required this.birthDay,
    required this.phoneNumber,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'normalizedName': normalizedName,
      'specializationId': specializationId,
      'description': description,
      'iraqiProvince': iraqiProvince,
      'birthDay': birthDay,
      'phoneNumber': phoneNumber,
      'location': location,
    };
  }
}

// نموذج توفر الطبيب
class DoctorAvailabilityModel {
  final int doctorId;
  final List<DayAvailabilityModel> days;

  DoctorAvailabilityModel({
    required this.doctorId,
    required this.days,
  });

  factory DoctorAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return DoctorAvailabilityModel(
      doctorId: json['doctorId'] ?? 0,
      days: (json['days'] as List<dynamic>?)
              ?.map((day) => DayAvailabilityModel.fromJson(day))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }
}

class DayAvailabilityModel {
  final int dayId;
  final String startTime;
  final String endTime;
  final int maxAppointments;

  DayAvailabilityModel({
    required this.dayId,
    required this.startTime,
    required this.endTime,
    required this.maxAppointments,
  });

  factory DayAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return DayAvailabilityModel(
      dayId: json['dayId'] ?? 0,
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      maxAppointments: json['maxAppointments'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayId': dayId,
      'startTime': startTime,
      'endTime': endTime,
      'maxAppointments': maxAppointments,
    };
  }

  DayAvailabilityModel copyWith({
    int? dayId,
    String? startTime,
    String? endTime,
    int? maxAppointments,
  }) {
    return DayAvailabilityModel(
      dayId: dayId ?? this.dayId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxAppointments: maxAppointments ?? this.maxAppointments,
    );
  }
}
