import 'package:get/get.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  
  final _notifications = <NotificationModel>[].obs;
  final _templates = <NotificationTemplate>[].obs;
  final _isLoading = false.obs;
  
  List<NotificationModel> get notifications => _notifications;
  List<NotificationTemplate> get templates => _templates;
  bool get isLoading => _isLoading.value;
  
  Future<void> fetchNotifications({
    String? status,
    String? channel,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _notifications.clear();
      }
      
      _isLoading.value = true;
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (status != null) queryParams['status'] = status;
      if (channel != null) queryParams['channel'] = channel;
      if (userId != null) queryParams['userId'] = userId;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      
      final response = await _apiService.get('/notifications', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final notificationsList = (data['notifications'] as List)
            .map((notification) => NotificationModel.fromJson(notification))
            .toList();
        
        if (refresh || page == 1) {
          _notifications.value = notificationsList;
        } else {
          _notifications.addAll(notificationsList);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch notifications: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> fetchTemplates({
    String? type,
    String? channel,
    bool? isActive,
    int page = 1,
    int limit = 10,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _templates.clear();
      }
      
      _isLoading.value = true;
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (type != null) queryParams['type'] = type;
      if (channel != null) queryParams['channel'] = channel;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      
      final response = await _apiService.get('/templates', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final templatesList = (data['templates'] as List)
            .map((template) => NotificationTemplate.fromJson(template))
            .toList();
        
        if (refresh || page == 1) {
          _templates.value = templatesList;
        } else {
          _templates.addAll(templatesList);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch templates: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<bool> sendNotification({
    required String templateId,
    required String userId,
    String? userSubscriptionId,
    required String channel,
    required String recipient,
    required Map<String, String> variables,
    DateTime? scheduleAt,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiService.post('/notifications/send', data: {
        'templateId': templateId,
        'userId': userId,
        'userSubscriptionId': userSubscriptionId,
        'channel': channel,
        'recipient': recipient,
        'variables': variables,
        'scheduleAt': scheduleAt?.toIso8601String(),
        'metadata': metadata,
      });
      
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Notification sent successfully');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to send notification');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send notification: $e');
      return false;
    }
  }
  
  Future<bool> createTemplate(Map<String, dynamic> templateData) async {
    try {
      final response = await _apiService.post('/templates', data: templateData);
      
      if (response.statusCode == 201) {
        final newTemplate = NotificationTemplate.fromJson(response.data['template']);
        _templates.insert(0, newTemplate);
        Get.snackbar('Success', 'Template created successfully');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to create template');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create template: $e');
      return false;
    }
  }
  
  Future<bool> updateTemplate(String id, Map<String, dynamic> templateData) async {
    try {
      final response = await _apiService.put('/templates/$id', data: templateData);
      
      if (response.statusCode == 200) {
        final updatedTemplate = NotificationTemplate.fromJson(response.data['template']);
        final index = _templates.indexWhere((template) => template.id == id);
        if (index != -1) {
          _templates[index] = updatedTemplate;
        }
        Get.snackbar('Success', 'Template updated successfully');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to update template');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update template: $e');
      return false;
    }
  }
  
  Future<bool> deleteTemplate(String id) async {
    try {
      final response = await _apiService.delete('/templates/$id');
      
      if (response.statusCode == 200) {
        _templates.removeWhere((template) => template.id == id);
        Get.snackbar('Success', 'Template deleted successfully');
        return true;
      } else {
        Get.snackbar('Error', 'Failed to delete template');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete template: $e');
      return false;
    }
  }
  
  Future<NotificationModel?> getNotificationById(String id) async {
    try {
      final response = await _apiService.get('/notifications/$id');
      
      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data['notification']);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch notification: $e');
    }
    return null;
  }
  
  Future<bool> retryNotification(String id) async {
    try {
      final response = await _apiService.post('/notifications/$id/retry');
      
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Notification retry initiated');
        fetchNotifications(refresh: true);
        return true;
      } else {
        Get.snackbar('Error', 'Failed to retry notification');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to retry notification: $e');
      return false;
    }
  }
  
  Future<bool> cancelNotification(String id) async {
    try {
      final response = await _apiService.put('/notifications/$id/cancel');
      
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Notification cancelled');
        fetchNotifications(refresh: true);
        return true;
      } else {
        Get.snackbar('Error', 'Failed to cancel notification');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel notification: $e');
      return false;
    }
  }
  
  void refreshNotifications() {
    fetchNotifications(refresh: true);
  }
  
  void refreshTemplates() {
    fetchTemplates(refresh: true);
  }
  
  Future<Map<String, dynamic>> resendNotification(String notificationId) async {
    try {
      final response = await _apiService.post('/notifications/$notificationId/retry');
      
      if (response.statusCode == 200) {
        fetchNotifications(refresh: true);
        return {'success': true, 'message': 'Notification resent successfully'};
      } else {
        return {'success': false, 'message': response.data['message'] ?? 'Failed to resend notification'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to resend notification: $e'};
    }
  }
  
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService.delete('/notifications/$notificationId');
      
      if (response.statusCode == 200) {
        fetchNotifications(refresh: true);
        return {'success': true, 'message': 'Notification deleted successfully'};
      } else {
        return {'success': false, 'message': response.data['message'] ?? 'Failed to delete notification'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to delete notification: $e'};
    }
  }
}
