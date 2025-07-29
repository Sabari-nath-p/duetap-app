part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  
  static const ONBOARDING = _Paths.ONBOARDING;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const USERS = _Paths.USERS;
  static const USER_DETAIL = _Paths.USER_DETAIL;
  static const PAYMENTS = _Paths.PAYMENTS;
  static const PAYMENT_DETAIL = _Paths.PAYMENT_DETAIL;
  static const NOTIFICATIONS = _Paths.NOTIFICATIONS;
  static const CREATE_NOTIFICATION = _Paths.CREATE_NOTIFICATION;
  static const TEMPLATES = _Paths.TEMPLATES;
  static const TEMPLATE_DETAIL = _Paths.TEMPLATE_DETAIL;
  static const ANALYTICS = _Paths.ANALYTICS;
  static const SETTINGS = _Paths.SETTINGS;
  static const PROFILE = _Paths.PROFILE;
  static const SUBSCRIPTION = _Paths.SUBSCRIPTION;
}

abstract class _Paths {
  _Paths._();
  
  static const ONBOARDING = '/onboarding';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const DASHBOARD = '/dashboard';
  static const USERS = '/users';
  static const USER_DETAIL = '/user-detail';
  static const PAYMENTS = '/payments';
  static const PAYMENT_DETAIL = '/payment-detail';
  static const NOTIFICATIONS = '/notifications';
  static const CREATE_NOTIFICATION = '/create-notification';
  static const TEMPLATES = '/templates';
  static const TEMPLATE_DETAIL = '/template-detail';
  static const ANALYTICS = '/analytics';
  static const SETTINGS = '/settings';
  static const PROFILE = '/profile';
  static const SUBSCRIPTION = '/subscription';
}
