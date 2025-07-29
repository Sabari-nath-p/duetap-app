import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/users_controller.dart';
import '../../models/user_model.dart';
import '../../utils/theme.dart';

class UsersView extends GetView<UsersController> {
  const UsersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.goToCreateUser,
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
                    hintText: 'Search users...',
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
                
                // Role Filter
                Row(
                  children: [
                    Text(
                      'Role:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(() => DropdownButton<String>(
                        value: controller.selectedRole,
                        isExpanded: true,
                        items: controller.roleOptions.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role == 'ALL' ? 'All Roles' : controller.getUserRoleBadgeText(role)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.onRoleFilterChanged(value);
                          }
                        },
                      )),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Users List
          Expanded(
            child: Obx(() {
              final users = controller.filteredUsers;
              
              if (controller.isLoading && users.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (users.isEmpty && !controller.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No users found',
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
                onRefresh: controller.refreshUsers,
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: users.length + (controller.hasMoreData ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= users.length) {
                      // Load more indicator
                      controller.loadMoreUsers();
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: const CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    final user = users[index];
                    return _buildUserCard(context, user);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserCard(BuildContext context, UserModel user) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => controller.goToUserDetail(user),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: user.profilePicture != null 
                        ? NetworkImage(user.profilePicture!) 
                        : null,
                    child: user.profilePicture == null 
                        ? Text(
                            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            // Role Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: controller.getUserRoleBadgeColor(user.role).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                controller.getUserRoleBadgeText(user.role),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: controller.getUserRoleBadgeColor(user.role),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            
                            // Status Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: user.isActive 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                user.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: user.isActive ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions
                  if (controller.canManageUser(user))
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'toggle_status':
                            controller.toggleUserStatus(user);
                            break;
                          case 'delete':
                            controller.deleteUser(user);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle_status',
                          child: Row(
                            children: [
                              Icon(
                                user.isActive ? Icons.block : Icons.check_circle,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(user.isActive ? 'Deactivate' : 'Activate'),
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
              SizedBox(height: 8.h),
              
              // Additional Info
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    user.phone.isNotEmpty ? user.phone : 'No phone',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.access_time,
                    size: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Joined ${_formatDate(user.createdAt)}',
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
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).round()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).round()} months ago';
    } else {
      return '${(difference.inDays / 365).round()} years ago';
    }
  }
}
