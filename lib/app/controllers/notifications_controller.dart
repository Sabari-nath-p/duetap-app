import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationsController extends GetxController {
  final NotificationService _notificationService = Get.find<NotificationService>();
  
  // Observable variables
  var isLoading = false.obs;
  var notifications = <NotificationModel>[].obs;
  var filteredNotifications = <NotificationModel>[].obs;
  var selectedTab = 0.obs;
  var searchQuery = ''.obs;
  var selectedStatus = 'ALL'.obs;
  var hasMoreData = true.obs;
  var currentPage = 1.obs;
  
  // Filters
  final statusOptions = ['ALL', 'SENT', 'PENDING', 'FAILED'];
  final tabLabels = ['All', 'SMS', 'Email', 'Push'];
  
  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    
    // Listen to search and filter changes
    debounce(searchQuery, (_) => applyFilters(), time: const Duration(milliseconds: 500));
    ever(selectedStatus, (_) => applyFilters());
    ever(selectedTab, (_) => applyFilters());
  }
  
  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      notifications.clear();
    }
    
    if (!hasMoreData.value && !refresh) return;
    
    try {
      isLoading.value = true;
      
      await _notificationService.fetchNotifications(
        page: currentPage.value,
        limit: 20,
        refresh: refresh,
      );
      
      final newNotifications = _notificationService.notifications;
      
      if (refresh) {
        notifications.value = newNotifications;
      } else {
        notifications.addAll(newNotifications);
      }
      
      hasMoreData.value = newNotifications.length >= 20;
      if (hasMoreData.value) {
        currentPage.value++;
      }
      
      applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> refreshNotifications() async {
    await loadNotifications(refresh: true);
  }
  
  Future<void> loadMoreNotifications() async {
    if (!isLoading.value && hasMoreData.value) {
      await loadNotifications();
    }
  }
  
  void applyFilters() {
    var filtered = notifications.toList();
    
    // Apply tab filter (channel)
    if (selectedTab.value > 0) {
      final channel = _getChannelFromTab(selectedTab.value);
      filtered = filtered.where((n) => n.channel == channel).toList();
    }
    
    // Apply status filter
    if (selectedStatus.value != 'ALL') {
      filtered = filtered.where((n) => n.status == selectedStatus.value).toList();
    }
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((n) => 
        (n.subject?.toLowerCase().contains(query) ?? false) ||
        n.content.toLowerCase().contains(query) ||
        n.recipient.toLowerCase().contains(query)
      ).toList();
    }
    
    // Sort by date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    filteredNotifications.value = filtered;
  }
  
  String _getChannelFromTab(int tabIndex) {
    switch (tabIndex) {
      case 1: return 'SMS';
      case 2: return 'EMAIL';
      case 3: return 'PUSH';
      default: return '';
    }
  }
  
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }
  
  void onStatusFilterChanged(String status) {
    selectedStatus.value = status;
  }
  
  void onTabChanged(int index) {
    selectedTab.value = index;
  }
  
  Future<void> resendNotification(NotificationModel notification) async {
    try {
      final result = await _notificationService.resendNotification(notification.id);
      
      if (result['success']) {
        Get.snackbar('Success', 'Notification resent successfully');
        refreshNotifications();
      } else {
        Get.snackbar('Error', result['message'] ?? 'Failed to resend notification');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend notification: $e');
    }
  }
  
  Future<void> deleteNotification(NotificationModel notification) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        final result = await _notificationService.deleteNotification(notification.id);
        
        if (result['success']) {
          notifications.removeWhere((n) => n.id == notification.id);
          applyFilters();
          Get.snackbar('Success', 'Notification deleted successfully');
        } else {
          Get.snackbar('Error', result['message'] ?? 'Failed to delete notification');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete notification: $e');
      }
    }
  }
  
  void goToNotificationDetail(NotificationModel notification) {
    Get.toNamed('/notification-detail', arguments: notification);
  }
  
  void goToCreateNotification() {
    Get.toNamed('/create-notification');
  }
  
  String getStatusIcon(String status) {
    switch (status) {
      case 'SENT': return '✓';
      case 'PENDING': return '⏳';
      case 'FAILED': return '✗';
      default: return '?';
    }
  }
  
  Color getStatusColor(String status) {
    switch (status) {
      case 'SENT': return Colors.green;
      case 'PENDING': return Colors.orange;
      case 'FAILED': return Colors.red;
      default: return Colors.grey;
    }
  }
  
  String getTypeIcon(String type) {
    switch (type) {
      case 'SMS': return '💬';
      case 'EMAIL': return '📧';
      case 'PUSH': return '🔔';
      default: return '📱';
    }
  }
  
  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
