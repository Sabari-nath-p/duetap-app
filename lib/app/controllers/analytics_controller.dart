import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class AnalyticsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Observable variables
  var isLoading = false.obs;
  var selectedDateRange = 'week'.obs;
  var selectedMetric = 'notifications'.obs;
  
  // Analytics data
  var totalNotifications = 0.obs;
  var sentNotifications = 0.obs;
  var failedNotifications = 0.obs;
  var deliveryRate = 0.0.obs;
  var totalRevenue = 0.0.obs;
  var activeSubscriptions = 0.obs;
  var totalUsers = 0.obs;
  var activeTemplates = 0.obs;
  
  // Chart data
  var notificationChartData = <Map<String, dynamic>>[].obs;
  var revenueChartData = <Map<String, dynamic>>[].obs;
  var channelDistribution = <Map<String, dynamic>>[].obs;
  var topTemplates = <Map<String, dynamic>>[].obs;
  
  // Options
  final dateRangeOptions = [
    {'value': 'week', 'label': 'Last 7 days'},
    {'value': 'month', 'label': 'Last 30 days'},
    {'value': '3months', 'label': 'Last 3 months'},
    {'value': 'year', 'label': 'Last year'},
  ];
  
  final metricOptions = [
    {'value': 'notifications', 'label': 'Notifications'},
    {'value': 'revenue', 'label': 'Revenue'},
    {'value': 'users', 'label': 'Users'},
    {'value': 'templates', 'label': 'Templates'},
  ];
  
  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
    
    // Listen to filter changes
    ever(selectedDateRange, (_) => loadAnalytics());
    ever(selectedMetric, (_) => loadAnalytics());
  }
  
  Future<void> loadAnalytics() async {
    try {
      isLoading.value = true;
      
      final queryParams = {
        'dateRange': selectedDateRange.value,
        'metric': selectedMetric.value,
      };
      
      final response = await _apiService.get('/analytics/dashboard', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final data = response.data;
        _updateAnalyticsData(data);
      } else {
        Get.snackbar('Error', 'Failed to load analytics');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load analytics: $e');
      _loadMockData(); // Load mock data if API fails
    } finally {
      isLoading.value = false;
    }
  }
  
  void _updateAnalyticsData(Map<String, dynamic> data) {
    // Update summary metrics
    totalNotifications.value = data['totalNotifications'] ?? 0;
    sentNotifications.value = data['sentNotifications'] ?? 0;
    failedNotifications.value = data['failedNotifications'] ?? 0;
    deliveryRate.value = data['deliveryRate']?.toDouble() ?? 0.0;
    totalRevenue.value = data['totalRevenue']?.toDouble() ?? 0.0;
    activeSubscriptions.value = data['activeSubscriptions'] ?? 0;
    totalUsers.value = data['totalUsers'] ?? 0;
    activeTemplates.value = data['activeTemplates'] ?? 0;
    
    // Update chart data
    notificationChartData.value = List<Map<String, dynamic>>.from(data['notificationChart'] ?? []);
    revenueChartData.value = List<Map<String, dynamic>>.from(data['revenueChart'] ?? []);
    channelDistribution.value = List<Map<String, dynamic>>.from(data['channelDistribution'] ?? []);
    topTemplates.value = List<Map<String, dynamic>>.from(data['topTemplates'] ?? []);
  }
  
  void _loadMockData() {
    // Mock data for development
    totalNotifications.value = 1250;
    sentNotifications.value = 1180;
    failedNotifications.value = 70;
    deliveryRate.value = 94.4;
    totalRevenue.value = 25840.50;
    activeSubscriptions.value = 142;
    totalUsers.value = 1520;
    activeTemplates.value = 28;
    
    // Mock chart data
    notificationChartData.value = [
      {'date': '2024-01-15', 'count': 150},
      {'date': '2024-01-16', 'count': 180},
      {'date': '2024-01-17', 'count': 165},
      {'date': '2024-01-18', 'count': 220},
      {'date': '2024-01-19', 'count': 195},
      {'date': '2024-01-20', 'count': 240},
      {'date': '2024-01-21', 'count': 200},
    ];
    
    revenueChartData.value = [
      {'date': '2024-01-15', 'amount': 3200.50},
      {'date': '2024-01-16', 'amount': 3800.75},
      {'date': '2024-01-17', 'amount': 3500.25},
      {'date': '2024-01-18', 'amount': 4200.00},
      {'date': '2024-01-19', 'amount': 3900.50},
      {'date': '2024-01-20', 'amount': 4500.75},
      {'date': '2024-01-21', 'amount': 3940.25},
    ];
    
    channelDistribution.value = [
      {'channel': 'SMS', 'count': 650, 'percentage': 52.0},
      {'channel': 'EMAIL', 'count': 450, 'percentage': 36.0},
      {'channel': 'PUSH', 'count': 150, 'percentage': 12.0},
    ];
    
    topTemplates.value = [
      {'name': 'Appointment Reminder', 'count': 320, 'channel': 'SMS'},
      {'name': 'Payment Due Notice', 'count': 280, 'channel': 'EMAIL'},
      {'name': 'Welcome Message', 'count': 210, 'channel': 'PUSH'},
      {'name': 'Appointment Confirmation', 'count': 180, 'channel': 'SMS'},
      {'name': 'Payment Receipt', 'count': 160, 'channel': 'EMAIL'},
    ];
  }
  
  Future<void> refreshAnalytics() async {
    await loadAnalytics();
  }
  
  void onDateRangeChanged(String dateRange) {
    selectedDateRange.value = dateRange;
  }
  
  void onMetricChanged(String metric) {
    selectedMetric.value = metric;
  }
  
  String getDateRangeLabel() {
    final option = dateRangeOptions.firstWhere(
      (option) => option['value'] == selectedDateRange.value,
      orElse: () => dateRangeOptions.first,
    );
    return option['label'] as String;
  }
  
  String getMetricLabel() {
    final option = metricOptions.firstWhere(
      (option) => option['value'] == selectedMetric.value,
      orElse: () => metricOptions.first,
    );
    return option['label'] as String;
  }
  
  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
  
  String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }
  
  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
  
  Color getChannelColor(String channel) {
    switch (channel) {
      case 'SMS': return Colors.green;
      case 'EMAIL': return Colors.blue;
      case 'PUSH': return Colors.orange;
      default: return Colors.grey;
    }
  }
  
  IconData getChannelIcon(String channel) {
    switch (channel) {
      case 'SMS': return Icons.sms;
      case 'EMAIL': return Icons.email;
      case 'PUSH': return Icons.notifications;
      default: return Icons.device_unknown;
    }
  }
  
  void exportAnalytics() async {
    try {
      Get.snackbar('Info', 'Preparing analytics export...');
      
      final response = await _apiService.get('/analytics/export', queryParameters: {
        'dateRange': selectedDateRange.value,
        'format': 'pdf',
      });
      
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Analytics exported successfully');
        // Handle file download here
      } else {
        Get.snackbar('Error', 'Failed to export analytics');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to export analytics: $e');
    }
  }
  
  void shareAnalytics() async {
    try {
      Get.snackbar('Info', 'Preparing analytics report...');
      
      final response = await _apiService.post('/analytics/share', data: {
        'dateRange': selectedDateRange.value,
        'metrics': [selectedMetric.value],
      });
      
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Analytics report shared successfully');
      } else {
        Get.snackbar('Error', 'Failed to share analytics');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to share analytics: $e');
    }
  }
}
