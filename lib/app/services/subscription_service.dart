import 'package:get/get.dart';
import '../models/subscription_model.dart';
import 'api_service.dart';

class SubscriptionService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  
  final _subscriptions = <UserSubscription>[].obs;
  final _payments = <Payment>[].obs;
  final _isLoading = false.obs;
  
  List<UserSubscription> get subscriptions => _subscriptions;
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading.value;
  
  Future<void> fetchSubscriptions({
    String? status,
    String? userId,
    int page = 1,
    int limit = 10,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _subscriptions.clear();
      }
      
      _isLoading.value = true;
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (status != null) queryParams['status'] = status;
      if (userId != null) queryParams['userId'] = userId;
      
      final response = await _apiService.get('/subscriptions', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final subscriptionsList = (data['data'] as List)
            .map((sub) => UserSubscription.fromJson(sub))
            .toList();
        
        if (refresh || page == 1) {
          _subscriptions.value = subscriptionsList;
        } else {
          _subscriptions.addAll(subscriptionsList);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch subscriptions: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<bool> createSubscription(Map<String, dynamic> subscriptionData) async {
    try {
      final response = await _apiService.post('/subscriptions', data: subscriptionData);
      
      if (response.statusCode == 200) {
        final newSubscription = UserSubscription.fromJson(response.data);
        _subscriptions.insert(0, newSubscription);
        Get.snackbar('Success', 'Subscription created successfully');
        return true;
      } else {
        Get.snackbar('Error', response.statusMessage ?? 'Failed to create subscription');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create subscription: $e');
      return false;
    }
  }
  
  Future<bool> updateSubscription(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/subscriptions/$id', data: data);
      
      if (response.statusCode == 200) {
        final updatedSubscription = UserSubscription.fromJson(response.data);
        final index = _subscriptions.indexWhere((sub) => sub.id == id);
        if (index != -1) {
          _subscriptions[index] = updatedSubscription;
        }
        Get.snackbar('Success', 'Subscription updated successfully');
        return true;
      } else {
        Get.snackbar('Error', response.statusMessage ?? 'Failed to update subscription');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update subscription: $e');
      return false;
    }
  }
  
  Future<void> fetchPayments({
    String? status,
    String? userSubscriptionId,
    int page = 1,
    int limit = 10,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _payments.clear();
      }
      
      _isLoading.value = true;
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (status != null) queryParams['status'] = status;
      if (userSubscriptionId != null) queryParams['userSubscriptionId'] = userSubscriptionId;
      
      final response = await _apiService.get('/payments', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final paymentsList = (data['data'] as List)
            .map((payment) => Payment.fromJson(payment))
            .toList();
        
        if (refresh || page == 1) {
          _payments.value = paymentsList;
        } else {
          _payments.addAll(paymentsList);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch payments: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<Map<String, dynamic>?> createPaymentOrder({
    required String userSubscriptionId,
    required double amount,
    required String currency,
    required String paymentMethod,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.post('/payments/create-order', data: {
        'userSubscriptionId': userSubscriptionId,
        'amount': amount,
        'currency': currency,
        'paymentMethod': paymentMethod,
        'metadata': metadata,
      });
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        Get.snackbar('Error', response.statusMessage ?? 'Failed to create payment order');
        return null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create payment order: $e');
      return null;
    }
  }
}
