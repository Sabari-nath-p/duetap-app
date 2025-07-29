import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/dashboard_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/chart_widget.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Obx(() => Text(
              'Welcome back, ${controller.userName}',
              style: AppTextStyles.body2,
            )),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/notifications'),
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary,
                ),
                Obx(() => controller.unreadNotifications > 0
                    ? Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12.w,
                            minHeight: 12.h,
                          ),
                          child: Text(
                            '${controller.unreadNotifications}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/profile'),
            icon: CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 18.w,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats
              Obx(() => GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1.6,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatsCard(
                    title: 'Total Users',
                    value: '${controller.totalUsers.value}',
                    icon: Icons.people,
                    color: AppColors.primary,
                    trend: '+${controller.userGrowth.value}%',
                    isPositive: controller.userGrowth.value >= 0,
                  ),
                  StatsCard(
                    title: 'Active Subscriptions',
                    value: '${controller.activeSubscriptions.value}',
                    icon: Icons.subscriptions,
                    color: AppColors.success,
                    trend: '+${controller.subscriptionGrowth.value}%',
                    isPositive: controller.subscriptionGrowth.value >= 0,
                  ),
                  StatsCard(
                    title: 'Notifications Sent',
                    value: '${controller.notificationsSent.value}',
                    icon: Icons.send,
                    color: AppColors.info,
                    trend: '+${controller.notificationGrowth.value}%',
                    isPositive: controller.notificationGrowth.value >= 0,
                  ),
                  StatsCard(
                    title: 'Revenue',
                    value: '\$${controller.totalRevenue.value}',
                    icon: Icons.attach_money,
                    color: AppColors.warning,
                    trend: '+${controller.revenueGrowth.value}%',
                    isPositive: controller.revenueGrowth.value >= 0,
                  ),
                ],
              )),
              SizedBox(height: 24.h),
              
              // Charts Section
              Text(
                'Analytics',
                style: AppTextStyles.h3,
              ),
              SizedBox(height: 16.h),
              
              // Revenue Chart
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Revenue Overview',
                          style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Last 30 days',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Obx(() => ChartWidget(
                      title: 'Revenue Over Time',
                      data: controller.revenueChartData,
                    )),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              
              // Recent Activities
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Activities',
                          style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed('/notifications'),
                          child: Text(
                            'View All',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Obx(() => ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.recentActivities.length,
                      separatorBuilder: (context, index) => Divider(
                        color: AppColors.divider,
                        height: 1.h,
                      ),
                      itemBuilder: (context, index) {
                        final activity = controller.recentActivities[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 20.r,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Icon(
                              Icons.history, // Default icon
                              color: AppColors.primary,
                              size: 20.sp,
                            ),
                          ),
                          title: Text(
                            activity.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            _formatTime(activity.timestamp),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    )),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() => BottomNavigationBar(
      currentIndex: controller.currentIndex,
      onTap: controller.onBottomNavTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payment),
          label: 'Payments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analytics',
        ),
      ],
    ));
  }
  
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
