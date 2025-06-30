import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/config/api_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'routes/app_routes.dart';
import 'controllers/auth_controller.dart';
import 'controllers/general_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة GetStorage
  await GetStorage.init();

  // تهيئة API Config
  ApiConfig.initialize();

  runApp(MedicsApp());
}

class MedicsApp extends StatelessWidget {
  MedicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,

      // Localization
      locale: const Locale('ar', 'SA'),
      fallbackLocale: const Locale('ar', 'SA'),

      // Routes
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,

      // Controllers Binding
      initialBinding: InitialBinding(),

      // Global Directionality for RTL
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}

// ربط Controllers الأساسية
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Controllers أساسية يجب تهيئتها في بداية التطبيق
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<GeneralController>(GeneralController(), permanent: true);
  }
}
