import 'package:get/get.dart';
import '../models/analytics_model.dart';
import 'api_service.dart';

class AnalyticsService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  
  final _analytics = Rx<Analytics?>(null);
  final _isLoading = false.obs;
  
  Analytics? get analytics => _analytics.value;
  bool get isLoading => _isLoading.value;
  
  Future<void> fetchDashboardAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? clientId,
  }) async {
    try {
      _isLoading.value = true;
      
      final queryParams = <String, dynamic>{};
      
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }
      if (clientId != null) {
        queryParams['clientId'] = clientId;
      }
      
      final response = await _apiService.get('/analytics/dashboard', 
          queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      if (response.statusCode == 200) {
        _analytics.value = Analytics.fromJson(response.data);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch analytics: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> refreshAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? clientId,
  }) async {
    await fetchDashboardAnalytics(
      startDate: startDate,
      endDate: endDate,
      clientId: clientId,
    );
  }
}
