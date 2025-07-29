import 'package:get/get.dart';
import '../models/analytics_model.dart';
// import '../services/analytics_service.dart';
import '../services/auth_service.dart';

class DashboardController extends GetxController {
  // final AnalyticsService _analyticsService = Get.find<AnalyticsService>();
  final AuthService _authService = Get.find<AuthService>();
  
  final _analytics = Rx<Analytics?>(null);
  final _isLoading = false.obs;
  final _recentActivities = <Activity>[].obs;
  final _userName = ''.obs;
  final _unreadNotifications = 0.obs;
  final _currentIndex = 0.obs;
  
  // Dashboard stats observables
  final _totalUsers = 0.obs;
  final _activeSubscriptions = 0.obs;
  final _notificationsSent = 0.obs;
  final _totalRevenue = 0.0.obs;
  final _userGrowth = 0.0.obs;
  final _subscriptionGrowth = 0.0.obs;
  final _notificationGrowth = 0.0.obs;
  final _revenueGrowth = 0.0.obs;
  final _revenueChartData = <RevenueData>[].obs;
  
  Analytics? get analytics => _analytics.value;
  bool get isLoading => _isLoading.value;
  List<Activity> get recentActivities => _recentActivities;
  String get userName => _userName.value;
  int get unreadNotifications => _unreadNotifications.value;
  int get currentIndex => _currentIndex.value;
  
  // Dashboard stats getters
  RxInt get totalUsers => _totalUsers;
  RxInt get activeSubscriptions => _activeSubscriptions;
  RxInt get notificationsSent => _notificationsSent;
  RxDouble get totalRevenue => _totalRevenue;
  RxDouble get userGrowth => _userGrowth;
  RxDouble get subscriptionGrowth => _subscriptionGrowth;
  RxDouble get notificationGrowth => _notificationGrowth;
  RxDouble get revenueGrowth => _revenueGrowth;
  RxList<RevenueData> get revenueChartData => _revenueChartData;
  
  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }
  
  void _initializeData() {
    final user = _authService.currentUser;
    if (user != null) {
      _userName.value = user.firstName;
    }
    
    fetchDashboardData();
  }
  
  Future<void> fetchDashboardData() async {
    try {
      _isLoading.value = true;
      
      // Get analytics for the last 30 days
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      
      // TODO: Re-enable when analytics service is fixed
      // await _analyticsService.fetchDashboardAnalytics(
      //   startDate: startDate,
      //   endDate: endDate,
      // );
      
      // final analyticsData = _analyticsService.analytics;
      // if (analyticsData != null) {
      //   _analytics.value = analyticsData;
      //   _recentActivities.value = analyticsData.recentActivities;
        
      //   // Update individual stats
      //   _totalUsers.value = analyticsData.summary.totalUsers;
      //   _activeSubscriptions.value = analyticsData.summary.activeSubscriptions;
      //   _notificationsSent.value = analyticsData.summary.notificationsSent;
      //   _totalRevenue.value = analyticsData.summary.totalRevenue;
      //   _userGrowth.value = analyticsData.summary.userGrowth;
      //   _revenueGrowth.value = analyticsData.summary.revenueGrowth;
      //   _notificationGrowth.value = analyticsData.summary.notificationGrowth;
      //   _subscriptionGrowth.value = 0.0; // Not provided in summary, defaulting to 0
      //   _revenueChartData.value = analyticsData.charts.revenueOverTime;
      // }
      
      // Mock data for now
      _totalUsers.value = 1250;
      _activeSubscriptions.value = 89;
      _notificationsSent.value = 12400;
      _totalRevenue.value = 45670.0;
      _userGrowth.value = 12.5;
      _revenueGrowth.value = 8.3;
      _notificationGrowth.value = 15.2;
      _subscriptionGrowth.value = 5.4;
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dashboard data: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> refreshData() async {
    await fetchDashboardData();
  }
  
  Future<void> refreshDashboard() async {
    await fetchDashboardData();
  }
  
  void setCurrentIndex(int index) {
    _currentIndex.value = index;
  }
  
  void onBottomNavTap(int index) {
    setCurrentIndex(index);
    switch (index) {
      case 0:
        // Dashboard - already here
        break;
      case 1:
        navigateToUsers();
        break;
      case 2:
        navigateToNotifications();
        break;
      case 3:
        navigateToAnalytics();
        break;
      case 4:
        navigateToSettings();
        break;
    }
  }
  
  void navigateToUsers() {
    Get.toNamed('/users');
  }
  
  void navigateToNotifications() {
    Get.toNamed('/notifications');
  }
  
  void navigateToAnalytics() {
    Get.toNamed('/analytics');
  }
  
  void navigateToSettings() {
    Get.toNamed('/settings');
  }
}
