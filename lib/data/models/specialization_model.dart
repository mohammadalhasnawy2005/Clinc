class SpecializationModel {
  final int id;
  final String name;
  final String normalizedName;

  SpecializationModel({
    required this.id,
    required this.name,
    required this.normalizedName,
  });

  factory SpecializationModel.fromJson(Map<String, dynamic> json) {
    return SpecializationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      normalizedName: json['normalizedName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'normalizedName': normalizedName,
    };
  }

  SpecializationModel copyWith({
    int? id,
    String? name,
    String? normalizedName,
  }) {
    return SpecializationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
    );
  }

  @override
  String toString() {
    return 'SpecializationModel(id: $id, name: $name, normalizedName: $normalizedName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpecializationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class DayModel {
  final int id;
  final String name;
  final String normalizedName;

  DayModel({
    required this.id,
    required this.name,
    required this.normalizedName,
  });

  factory DayModel.fromJson(Map<String, dynamic> json) {
    return DayModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      normalizedName: json['normalizedName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'normalizedName': normalizedName,
    };
  }

  DayModel copyWith({
    int? id,
    String? name,
    String? normalizedName,
  }) {
    return DayModel(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
    );
  }

  @override
  String toString() {
    return 'DayModel(id: $id, name: $name, normalizedName: $normalizedName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
