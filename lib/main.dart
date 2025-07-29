import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app/routes/app_pages.dart';
import 'app/services/api_service.dart';
import 'app/services/auth_service.dart';
import 'app/services/notification_service.dart';
import 'app/services/subscription_service.dart';
import 'app/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage
  await GetStorage.init();
  
  // Initialize Services in correct order
  Get.put(ApiService(), permanent: true);
  Get.put(AuthService(), permanent: true);
  Get.put(NotificationService(), permanent: true);
  Get.put(SubscriptionService(), permanent: true);
  // Get.put(UserService(), permanent: true);
  // Get.put(AnalyticsService(), permanent: true);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'ScheduRemind',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.interTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.interTextTheme(
              Theme.of(context).textTheme,
            ),
          ),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
