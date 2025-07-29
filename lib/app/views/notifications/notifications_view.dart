import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/notifications_controller.dart';
import '../../models/notification_model.dart';
import '../../utils/theme.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.goToCreateNotification,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16.w),
            color: AppColors.surface,
            child: Column(
              children: [
                // Search Field
                TextField(
                  onChanged: controller.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search notifications...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                
                // Status Filter
                Row(
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(() => DropdownButton<String>(
                        value: controller.selectedStatus.value,
                        isExpanded: true,
                        items: controller.statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status == 'ALL' ? 'All Status' : status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.onStatusFilterChanged(value);
                          }
                        },
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            color: AppColors.surface,
            child: Obx(() => TabBar(
              controller: TabController(
                length: controller.tabLabels.length,
                vsync: Scaffold.of(context),
                initialIndex: controller.selectedTab.value,
              ),
              onTap: controller.onTabChanged,
              tabs: controller.tabLabels.map((label) => Tab(text: label)).toList(),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
            )),
          ),
          
          // Notifications List
          Expanded(
            child: Obx(() {
              final notifications = controller.filteredNotifications;
              
              if (controller.isLoading.value && notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (notifications.isEmpty && !controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No notifications found',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Try adjusting your search or filters',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return RefreshIndicator(
                onRefresh: controller.refreshNotifications,
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: notifications.length + (controller.hasMoreData.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= notifications.length) {
                      // Load more indicator
                      controller.loadMoreNotifications();
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    final notification = notifications[index];
                    return _buildNotificationCard(context, notification);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationCard(BuildContext context, NotificationModel notification) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => controller.goToNotificationDetail(notification),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Channel Icon
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: _getChannelColor(notification.channel).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      controller.getTypeIcon(notification.channel),
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  
                  // Notification Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.subject ?? 'No Subject',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          notification.recipient,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          notification.content,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Status and Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Status Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: controller.getStatusColor(notification.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.getStatusIcon(notification.status),
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              notification.status,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: controller.getStatusColor(notification.status),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      
                      // Actions Menu
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'resend':
                              controller.resendNotification(notification);
                              break;
                            case 'delete':
                              controller.deleteNotification(notification);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          if (notification.status == 'FAILED')
                            PopupMenuItem(
                              value: 'resend',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  const Text('Resend'),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  size: 18.sp,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              
              // Timestamp and Details
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Created ${controller.formatDateTime(notification.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (notification.sentAt != null) ...[
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.send,
                      size: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Sent ${controller.formatDateTime(notification.sentAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              
              // Error Message (if any)
              if (notification.errorMessage != null) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16.sp,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          notification.errorMessage!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getChannelColor(String channel) {
    switch (channel) {
      case 'SMS': return Colors.green;
      case 'EMAIL': return Colors.blue;
      case 'PUSH': return Colors.orange;
      default: return AppColors.primary;
    }
  }
}
