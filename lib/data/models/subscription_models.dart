import 'doctor_model.dart';

class SubscriptionPackageModel {
  final int id;
  final String name;
  final String normalizedName;
  final double price;
  final double yearlyPrice;
  final int maxDailyAppointments;
  final int maxWeeklyDays;
  final bool showReviews;
  final bool showMessages;
  final bool eBooking;
  final bool ePayments;
  final bool makeOffers;
  final int maxActiveOffers;

  SubscriptionPackageModel({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.price,
    required this.yearlyPrice,
    required this.maxDailyAppointments,
    required this.maxWeeklyDays,
    required this.showReviews,
    required this.showMessages,
    required this.eBooking,
    required this.ePayments,
    required this.makeOffers,
    required this.maxActiveOffers,
  });

  factory SubscriptionPackageModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackageModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      normalizedName: json['normalizedName'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      yearlyPrice: (json['yearlyPrice'] ?? 0).toDouble(),
      maxDailyAppointments: json['maxDailyAppointments'] ?? 0,
      maxWeeklyDays: json['maxWeeklyDays'] ?? 0,
      showReviews: json['showReviews'] ?? false,
      showMessages: json['showMessages'] ?? false,
      eBooking: json['eBooking'] ?? false,
      ePayments: json['ePayments'] ?? false,
      makeOffers: json['makeOffers'] ?? false,
      maxActiveOffers: json['maxActiveOffers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'normalizedName': normalizedName,
      'price': price,
      'yearlyPrice': yearlyPrice,
      'maxDailyAppointments': maxDailyAppointments,
      'maxWeeklyDays': maxWeeklyDays,
      'showReviews': showReviews,
      'showMessages': showMessages,
      'eBooking': eBooking,
      'ePayments': ePayments,
      'makeOffers': makeOffers,
      'maxActiveOffers': maxActiveOffers,
    };
  }

  // حساب الخصم السنوي
  double get yearlyDiscount => (price * 12) - yearlyPrice;
  double get yearlyDiscountPercentage =>
      yearlyDiscount > 0 ? (yearlyDiscount / (price * 12)) * 100 : 0;

  // التحقق من الميزات
  bool get isFree => price == 0;
  bool get isPremium => id > 1; // أي باقة غير الأساسي

  SubscriptionPackageModel copyWith({
    int? id,
    String? name,
    String? normalizedName,
    double? price,
    double? yearlyPrice,
    int? maxDailyAppointments,
    int? maxWeeklyDays,
    bool? showReviews,
    bool? showMessages,
    bool? eBooking,
    bool? ePayments,
    bool? makeOffers,
    int? maxActiveOffers,
  }) {
    return SubscriptionPackageModel(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      price: price ?? this.price,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      maxDailyAppointments: maxDailyAppointments ?? this.maxDailyAppointments,
      maxWeeklyDays: maxWeeklyDays ?? this.maxWeeklyDays,
      showReviews: showReviews ?? this.showReviews,
      showMessages: showMessages ?? this.showMessages,
      eBooking: eBooking ?? this.eBooking,
      ePayments: ePayments ?? this.ePayments,
      makeOffers: makeOffers ?? this.makeOffers,
      maxActiveOffers: maxActiveOffers ?? this.maxActiveOffers,
    );
  }

  @override
  String toString() {
    return 'SubscriptionPackageModel(id: $id, name: $name, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionPackageModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DoctorSubscriptionModel {
  final int id;
  final DoctorModel doctor;
  final SubscriptionPackageModel package;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  DoctorSubscriptionModel({
    required this.id,
    required this.doctor,
    required this.package,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory DoctorSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return DoctorSubscriptionModel(
      id: json['id'] ?? 0,
      doctor: DoctorModel.fromJson(json['doctor'] ?? {}),
      package: SubscriptionPackageModel.fromJson(json['package'] ?? {}),
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] ?? '') ?? DateTime.now(),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor': doctor.toJson(),
      'package': package.toJson(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  // حساب الأيام المتبقية
  int get daysRemaining {
    final now = DateTime.now();
    if (endDate.isAfter(now)) {
      return endDate.difference(now).inDays;
    }
    return 0;
  }

  // التحقق من انتهاء الصلاحية
  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isExpiringSoon => daysRemaining <= 7 && daysRemaining > 0;

  DoctorSubscriptionModel copyWith({
    int? id,
    DoctorModel? doctor,
    SubscriptionPackageModel? package,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return DoctorSubscriptionModel(
      id: id ?? this.id,
      doctor: doctor ?? this.doctor,
      package: package ?? this.package,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'DoctorSubscriptionModel(id: $id, package: ${package.name}, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorSubscriptionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// نموذج إنشاء اشتراك
class CreateSubscriptionRequest {
  final int doctorId;
  final int packageId;

  CreateSubscriptionRequest({
    required this.doctorId,
    required this.packageId,
  });

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'packageId': packageId,
    };
  }
}

// نموذج الميزة
class FeatureModel {
  final int id;
  final String name;
  final String normalizedName;
  final String? description;
  final bool? isPremiumOnly;

  FeatureModel({
    required this.id,
    required this.name,
    required this.normalizedName,
    this.description,
    this.isPremiumOnly,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      normalizedName: json['normalizedName'] ?? '',
      description: json['description'],
      isPremiumOnly: json['isPremiumOnly'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'normalizedName': normalizedName,
      'description': description,
      'isPremiumOnly': isPremiumOnly,
    };
  }

  FeatureModel copyWith({
    int? id,
    String? name,
    String? normalizedName,
    String? description,
    bool? isPremiumOnly,
  }) {
    return FeatureModel(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      description: description ?? this.description,
      isPremiumOnly: isPremiumOnly ?? this.isPremiumOnly,
    );
  }

  @override
  String toString() {
    return 'FeatureModel(id: $id, name: $name, normalizedName: $normalizedName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// نموذج ميزات الطبيب
class DoctorFeatureModel {
  final int id;
  final DoctorModel doctor;
  final FeatureModel feature;
  final bool isEnabled;

  DoctorFeatureModel({
    required this.id,
    required this.doctor,
    required this.feature,
    required this.isEnabled,
  });

  factory DoctorFeatureModel.fromJson(Map<String, dynamic> json) {
    return DoctorFeatureModel(
      id: json['id'] ?? 0,
      doctor: DoctorModel.fromJson(json['doctor'] ?? {}),
      feature: FeatureModel.fromJson(json['feature'] ?? {}),
      isEnabled: json['isEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor': doctor.toJson(),
      'feature': feature.toJson(),
      'isEnabled': isEnabled,
    };
  }

  DoctorFeatureModel copyWith({
    int? id,
    DoctorModel? doctor,
    FeatureModel? feature,
    bool? isEnabled,
  }) {
    return DoctorFeatureModel(
      id: id ?? this.id,
      doctor: doctor ?? this.doctor,
      feature: feature ?? this.feature,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  String toString() {
    return 'DoctorFeatureModel(id: $id, feature: ${feature.name}, isEnabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctorFeatureModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
