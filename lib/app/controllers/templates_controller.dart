import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class TemplatesController extends GetxController {
  final NotificationService _notificationService = Get.find<NotificationService>();
  
  // Observable variables
  var isLoading = false.obs;
  var templates = <NotificationTemplate>[].obs;
  var filteredTemplates = <NotificationTemplate>[].obs;
  var selectedTab = 0.obs;
  var searchQuery = ''.obs;
  var selectedChannel = 'ALL'.obs;
  var selectedStatus = 'ALL'.obs;
  var hasMoreData = true.obs;
  var currentPage = 1.obs;
  
  // Filters
  final channelOptions = ['ALL', 'SMS', 'EMAIL', 'PUSH'];
  final statusOptions = ['ALL', 'ACTIVE', 'INACTIVE'];
  final tabLabels = ['All', 'Appointment', 'Payment', 'Marketing', 'System'];
  
  @override
  void onInit() {
    super.onInit();
    loadTemplates();
    
    // Listen to search and filter changes
    debounce(searchQuery, (_) => applyFilters(), time: const Duration(milliseconds: 500));
    ever(selectedChannel, (_) => applyFilters());
    ever(selectedStatus, (_) => applyFilters());
    ever(selectedTab, (_) => applyFilters());
  }
  
  Future<void> loadTemplates({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      templates.clear();
    }
    
    if (!hasMoreData.value && !refresh) return;
    
    try {
      isLoading.value = true;
      
      await _notificationService.fetchTemplates(
        page: currentPage.value,
        limit: 20,
        refresh: refresh,
      );
      
      final newTemplates = _notificationService.templates;
      
      if (refresh) {
        templates.value = newTemplates;
      } else {
        templates.addAll(newTemplates);
      }
      
      hasMoreData.value = newTemplates.length >= 20;
      if (hasMoreData.value) {
        currentPage.value++;
      }
      
      applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load templates: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> refreshTemplates() async {
    await loadTemplates(refresh: true);
  }
  
  Future<void> loadMoreTemplates() async {
    if (!isLoading.value && hasMoreData.value) {
      await loadTemplates();
    }
  }
  
  void applyFilters() {
    var filtered = templates.toList();
    
    // Apply tab filter (type)
    if (selectedTab.value > 0) {
      final type = _getTypeFromTab(selectedTab.value);
      filtered = filtered.where((t) => t.type == type).toList();
    }
    
    // Apply channel filter
    if (selectedChannel.value != 'ALL') {
      filtered = filtered.where((t) => t.channel == selectedChannel.value).toList();
    }
    
    // Apply status filter
    if (selectedStatus.value != 'ALL') {
      final isActive = selectedStatus.value == 'ACTIVE';
      filtered = filtered.where((t) => t.isActive == isActive).toList();
    }
    
    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((t) => 
        t.name.toLowerCase().contains(query) ||
        t.content.toLowerCase().contains(query) ||
        (t.subject?.toLowerCase().contains(query) ?? false)
      ).toList();
    }
    
    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));
    
    filteredTemplates.value = filtered;
  }
  
  String _getTypeFromTab(int tabIndex) {
    switch (tabIndex) {
      case 1: return 'APPOINTMENT';
      case 2: return 'PAYMENT';
      case 3: return 'MARKETING';
      case 4: return 'SYSTEM';
      default: return '';
    }
  }
  
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }
  
  void onChannelFilterChanged(String channel) {
    selectedChannel.value = channel;
  }
  
  void onStatusFilterChanged(String status) {
    selectedStatus.value = status;
  }
  
  void onTabChanged(int index) {
    selectedTab.value = index;
  }
  
  Future<void> toggleTemplateStatus(NotificationTemplate template) async {
    try {
      final result = await _notificationService.updateTemplate(
        template.id,
        {'isActive': !template.isActive},
      );
      
      if (result) {
        // Update local template
        final index = templates.indexWhere((t) => t.id == template.id);
        if (index != -1) {
          templates[index] = NotificationTemplate(
            id: template.id,
            name: template.name,
            type: template.type,
            channel: template.channel,
            subject: template.subject,
            content: template.content,
            variables: template.variables,
            isActive: !template.isActive,
            clientId: template.clientId,
            enablePaymentReminders: template.enablePaymentReminders,
            reminderDays: template.reminderDays,
            includePaymentLink: template.includePaymentLink,
            escalationTemplate: template.escalationTemplate,
            createdAt: template.createdAt,
            updatedAt: DateTime.now(),
            client: template.client,
          );
        }
        
        applyFilters();
        Get.snackbar('Success', 'Template ${template.isActive ? 'deactivated' : 'activated'} successfully');
      } else {
        Get.snackbar('Error', 'Failed to update template');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update template: $e');
    }
  }
  
  Future<void> deleteTemplate(NotificationTemplate template) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Are you sure you want to delete "${template.name}"?'),
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
        final result = await _notificationService.deleteTemplate(template.id);
        
        if (result) {
          templates.removeWhere((t) => t.id == template.id);
          applyFilters();
          Get.snackbar('Success', 'Template deleted successfully');
        } else {
          Get.snackbar('Error', 'Failed to delete template');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to delete template: $e');
      }
    }
  }
  
  Future<void> duplicateTemplate(NotificationTemplate template) async {
    try {
      final result = await _notificationService.createTemplate({
        'name': '${template.name} (Copy)',
        'type': template.type,
        'channel': template.channel,
        'subject': template.subject,
        'content': template.content,
        'variables': template.variables,
        'isActive': false,
        'enablePaymentReminders': template.enablePaymentReminders,
        'reminderDays': template.reminderDays,
        'includePaymentLink': template.includePaymentLink,
        'escalationTemplate': template.escalationTemplate,
      });
      
      if (result) {
        refreshTemplates();
        Get.snackbar('Success', 'Template duplicated successfully');
      } else {
        Get.snackbar('Error', 'Failed to duplicate template');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to duplicate template: $e');
    }
  }
  
  void goToTemplateDetail(NotificationTemplate template) {
    Get.toNamed('/template-detail', arguments: template);
  }
  
  void goToCreateTemplate() {
    Get.toNamed('/create-template');
  }
  
  void goToEditTemplate(NotificationTemplate template) {
    Get.toNamed('/edit-template', arguments: template);
  }
  
  String getChannelIcon(String channel) {
    switch (channel) {
      case 'SMS': return '💬';
      case 'EMAIL': return '📧';
      case 'PUSH': return '🔔';
      default: return '📱';
    }
  }
  
  Color getChannelColor(String channel) {
    switch (channel) {
      case 'SMS': return Colors.green;
      case 'EMAIL': return Colors.blue;
      case 'PUSH': return Colors.orange;
      default: return Colors.grey;
    }
  }
  
  String getTypeIcon(String type) {
    switch (type) {
      case 'APPOINTMENT': return '📅';
      case 'PAYMENT': return '💳';
      case 'MARKETING': return '📢';
      case 'SYSTEM': return '⚙️';
      default: return '📝';
    }
  }
  
  Color getTypeColor(String type) {
    switch (type) {
      case 'APPOINTMENT': return Colors.blue;
      case 'PAYMENT': return Colors.green;
      case 'MARKETING': return Colors.purple;
      case 'SYSTEM': return Colors.grey;
      default: return Colors.grey;
    }
  }
  
  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).round()}w ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
