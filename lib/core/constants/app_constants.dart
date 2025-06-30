class AppConstants {
  AppConstants._();

  // API Configuration
  static const String baseUrl = 'http://localhost:5282/api';
  static const String imagesBaseUrl = '$baseUrl/images';

  // API Endpoints
  static const String userSignUp = '/User/signup';
  static const String userSignIn = '/User/signin';
  static const String userProfileImage = '/User/profile-image';
  static const String specializations = '/Specialization';
  static const String days = '/Day';
  static const String doctors = '/Doctor';
  static const String doctorAvailability = '/DoctorAvailability';
  static const String doctorFeature = '/DoctorFeature';
  static const String doctorSubscription = '/DoctorSubscription';
  static const String subscriptionPackages = '/SubscriptionPackages';
  static const String features = '/Feature';
  static const String appointments = '/Appointment';
  static const String appointmentToggleStatus = '/Appointment/toggle-status';
  static const String appointmentComplete = '/Appointment/complete';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userTypeKey = 'user_type';
  static const String isFirstTimeKey = 'is_first_time';
  static const String selectedLanguageKey = 'selected_language';

  // User Types
  static const String userTypePatient = 'patient';
  static const String userTypeDoctor = 'doctor';

  // Appointment Status
  static const int appointmentStatusPending = 0;
  static const int appointmentStatusApproved = 1;
  static const int appointmentStatusRejected = 2;
  static const int appointmentStatusCompleted = 3;

  // Payment Status
  static const int paymentStatusUnpaid = 0;
  static const int paymentStatusPaidOnline = 1;
  static const int paymentStatusPaidInClinic = 2;

  // Subscription Packages
  static const int packageBasic = 1;
  static const int packageGold = 2;
  static const int packageDiamond = 3;
  static const int packagePremium = 4;

  // Days of Week (من API /Day)
  static const int daySaturday = 1;
  static const int daySunday = 2;
  static const int dayMonday = 3;
  static const int dayTuesday = 4;
  static const int dayWednesday = 5;
  static const int dayThursday = 6;
  static const int dayFriday = 7;

  // App Settings
  static const int splashDuration = 3; // seconds
  static const int onboardingPagesCount = 3;
  static const int requestTimeoutDuration = 30; // seconds
  static const int appointmentApprovalTimeoutHours = 48;

  // Pagination
  static const int defaultPageSize = 10;
  static const int doctorsPageSize = 20;
  static const int appointmentsPageSize = 15;

  // Image Constraints
  static const int maxImageSizeMB = 5;
  static const int profileImageQuality = 85;
  static const double profileImageMaxWidth = 800;
  static const double profileImageMaxHeight = 800;

  // Animation Durations
  static const int shortAnimationDuration = 300; // ms
  static const int mediumAnimationDuration = 500; // ms
  static const int longAnimationDuration = 800; // ms

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 32;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // RegExp Patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^[0-9]{10,15}$';
  static const String namePattern = r'^[\u0600-\u06FFa-zA-Z\s]+$';

  // Error Messages
  static const String networkErrorMessage = 'فشل في الاتصال بالخادم';
  static const String timeoutErrorMessage = 'انتهت مهلة الاتصال';
  static const String unauthorizedErrorMessage = 'غير مخول للوصول';
  static const String notFoundErrorMessage = 'البيانات غير موجودة';
  static const String serverErrorMessage = 'خطأ في الخادم';
  static const String unknownErrorMessage = 'حدث خطأ غير معروف';

  // Success Messages
  static const String loginSuccessMessage = 'تم تسجيل الدخول بنجاح';
  static const String signUpSuccessMessage = 'تم إنشاء الحساب بنجاح';
  static const String appointmentBookedMessage = 'تم حجز الموعد بنجاح';
  static const String appointmentCancelledMessage = 'تم إلغاء الموعد';
  static const String profileUpdatedMessage = 'تم تحديث الملف الشخصي';

  // Map Configuration
  static const double defaultLatitude = 32.6167; // بغداد
  static const double defaultLongitude = 44.3667;
  static const double defaultZoom = 10.0;
  static const double markerIconSize = 50.0;

  // Features IDs (من API /Feature)
  static const int featureShowReviews = 1;
  static const int featureShowMessages = 2;
  static const int featureEBooking = 3;
  static const int featureEPayments = 4;
}
