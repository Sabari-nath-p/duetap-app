import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/templates_controller.dart';
import '../../models/notification_model.dart';
import '../../utils/theme.dart';

class TemplatesView extends GetView<TemplatesController> {
  const TemplatesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Templates'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.goToCreateTemplate,
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
                    hintText: 'Search templates...',
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
                
                // Filters Row
                Row(
                  children: [
                    // Channel Filter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Channel:',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Obx(() => DropdownButton<String>(
                            value: controller.selectedChannel.value,
                            isExpanded: true,
                            items: controller.channelOptions.map((channel) {
                              return DropdownMenuItem(
                                value: channel,
                                child: Text(channel == 'ALL' ? 'All Channels' : channel),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.onChannelFilterChanged(value);
                              }
                            },
                          )),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    
                    // Status Filter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status:',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Obx(() => DropdownButton<String>(
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
                        ],
                      ),
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
              isScrollable: true,
            )),
          ),
          
          // Templates List
          Expanded(
            child: Obx(() {
              final templates = controller.filteredTemplates;
              
              if (controller.isLoading.value && templates.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (templates.isEmpty && !controller.isLoading.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 64.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No templates found',
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
                onRefresh: controller.refreshTemplates,
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: templates.length + (controller.hasMoreData.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= templates.length) {
                      // Load more indicator
                      controller.loadMoreTemplates();
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    final template = templates[index];
                    return _buildTemplateCard(context, template);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTemplateCard(BuildContext context, NotificationTemplate template) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => controller.goToTemplateDetail(template),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Type and Channel Icons
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: controller.getTypeColor(template.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          controller.getTypeIcon(template.type),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: controller.getChannelColor(template.channel).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          controller.getChannelIcon(template.channel),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  
                  // Template Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            // Type Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: controller.getTypeColor(template.type).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                template.type,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: controller.getTypeColor(template.type),
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            
                            // Channel Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: controller.getChannelColor(template.channel).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                template.channel,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: controller.getChannelColor(template.channel),
                                ),
                              ),
                            ),
                          ],
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
                          color: template.isActive 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          template.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: template.isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      
                      // Actions Menu
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              controller.goToEditTemplate(template);
                              break;
                            case 'duplicate':
                              controller.duplicateTemplate(template);
                              break;
                            case 'toggle_status':
                              controller.toggleTemplateStatus(template);
                              break;
                            case 'delete':
                              controller.deleteTemplate(template);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                const Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.copy,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                const Text('Duplicate'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle_status',
                            child: Row(
                              children: [
                                Icon(
                                  template.isActive ? Icons.pause : Icons.play_arrow,
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(template.isActive ? 'Deactivate' : 'Activate'),
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
              
              // Subject (if available)
              if (template.subject != null) ...[
                Text(
                  'Subject: ${template.subject}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
              ],
              
              // Content Preview
              Text(
                template.content,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              
              // Variables and Features
              Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: [
                  // Variables count
                  if (template.variables.isNotEmpty)
                    _buildFeatureChip(
                      '${template.variables.length} variables',
                      Icons.code,
                      Colors.blue,
                    ),
                  
                  // Payment reminders
                  if (template.enablePaymentReminders)
                    _buildFeatureChip(
                      'Payment reminders',
                      Icons.payment,
                      Colors.green,
                    ),
                  
                  // Payment link
                  if (template.includePaymentLink)
                    _buildFeatureChip(
                      'Payment link',
                      Icons.link,
                      Colors.orange,
                    ),
                  
                  // Escalation
                  if (template.escalationTemplate)
                    _buildFeatureChip(
                      'Escalation',
                      Icons.warning,
                      Colors.red,
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              
              // Timestamp
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Updated ${controller.formatDateTime(template.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.sp,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
