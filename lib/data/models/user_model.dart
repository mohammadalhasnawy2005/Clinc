class UserModel {
  final String id;
  final String name;
  final String normalizedName;
  final String phoneNumber;
  final String email;
  final String? profileImage;
  final int? age;
  final String? gender;

  UserModel({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.phoneNumber,
    required this.email,
    this.profileImage,
    this.age,
    this.gender,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      normalizedName: json['normalizedName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
      age: json['age'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'normalizedName': normalizedName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImage': profileImage,
      'age': age,
      'gender': gender,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? normalizedName,
    String? phoneNumber,
    String? email,
    String? profileImage,
    int? age,
    String? gender,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      age: age ?? this.age,
      gender: gender ?? this.gender,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, phoneNumber: $phoneNumber, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// نموذج تسجيل المستخدم
class SignUpRequest {
  final String name;
  final String phoneNumber;
  final String password;
  final String email;

  SignUpRequest({
    required this.name,
    required this.phoneNumber,
    required this.password,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'password': password,
      'email': email,
    };
  }
}

// نموذج تسجيل الدخول
class SignInRequest {
  final String phoneNumber;
  final String password;

  SignInRequest({
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'password': password,
    };
  }
}

// نموذج استجابة المصادقة
class AuthResponse {
  final String userId;
  final String name;
  final String phoneNumber;
  final String email;
  final String token;

  AuthResponse({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'token': token,
    };
  }
}
