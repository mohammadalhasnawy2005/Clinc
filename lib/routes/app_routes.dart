import 'package:get/get.dart';
import '../views/splash/splash_screen.dart';
import '../views/onboarding/onboarding_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/signup_screen.dart';
import '../views/home/home_screen.dart';
import '../views/navigation/main_navigation.dart';
import '../views/doctor/doctor_profile_screen.dart';
import '../views/appointment/appointment_booking_screen.dart';
import '../views/appointment/my_appointments_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/widgets/chat_floating_button.dart';
import '../controllers/doctor_controller.dart';
import '../controllers/appointment_controller.dart';
import '../controllers/subscription_controller.dart';

class AppRoutes {
  AppRoutes._();

  // Route Names
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String mainNavigation = '/main-navigation';
  static const String doctorProfile = '/doctor-profile';
  static const String createClinic = '/create-clinic';
  static const String doctorDashboard = '/doctor-dashboard';
  static const String appointmentBooking = '/appointment-booking';
  static const String appointmentDetails = '/appointment-details';
  static const String myAppointments = '/my-appointments';
  static const String subscriptionPackages = '/subscription-packages';
  static const String profile = '/profile';
  static const String chat = '/chat';

  // Routes List
  static List<GetPage> routes = [
    // Splash & Onboarding
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
    ),

    // Authentication
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: signup,
      page: () => const SignUpScreen(),
    ),

    // Main Navigation
    GetPage(
      name: home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: mainNavigation,
      page: () => const MainNavigation(),
    ),

    // Doctor Screens
    GetPage(
      name: doctorProfile,
      page: () => const DoctorProfileScreen(),
      binding: DoctorBinding(),
    ),

    // Appointment Screens
    GetPage(
      name: appointmentBooking,
      page: () => const AppointmentBookingScreen(),
      binding: AppointmentBinding(),
    ),
    GetPage(
      name: myAppointments,
      page: () => const MyAppointmentsScreen(),
      binding: AppointmentBinding(),
    ),

    // Profile & Settings
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
    ),

    // Chat
    GetPage(
      name: chat,
      page: () => const ChatPage(),
    ),
  ];
}

// Controller Bindings - تم إصلاحها
class DoctorBinding extends Bindings {
  @override
  void dependencies() {
    // استخدم lazyPut مع condition للتجنب إعادة الإنشاء
    if (!Get.isRegistered<DoctorController>()) {
      Get.lazyPut<DoctorController>(() => DoctorController());
    }
  }
}

class AppointmentBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppointmentController>()) {
      Get.lazyPut<AppointmentController>(() => AppointmentController());
    }
  }
}

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<SubscriptionController>()) {
      Get.lazyPut<SubscriptionController>(() => SubscriptionController());
    }
  }
}
