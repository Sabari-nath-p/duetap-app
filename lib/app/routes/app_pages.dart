import 'package:get/get.dart';
import '../views/auth/login_view.dart';
import '../views/dashboard/dashboard_view.dart';
import '../views/onboarding/onboarding_view.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/onboarding_controller.dart';
import '../controllers/login_controller.dart';
import '../middleware/auth_middleware.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.DASHBOARD;

  static final routes = [
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OnboardingController>(() => OnboardingController());
      }),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
