import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class UsersController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final AuthService _authService = Get.find<AuthService>();
  
  final _users = <UserModel>[].obs;
  final _isLoading = false.obs;
  final _searchQuery = ''.obs;
  final _selectedRole = 'ALL'.obs;
  final _currentPage = 1.obs;
  final _hasMoreData = true.obs;
  
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get selectedRole => _selectedRole.value;
  int get currentPage => _currentPage.value;
  bool get hasMoreData => _hasMoreData.value;
  
  List<UserModel> get filteredUsers {
    return _users.where((user) {
      final matchesSearch = searchQuery.isEmpty || 
          user.firstName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.lastName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(searchQuery.toLowerCase());
      
      final matchesRole = selectedRole == 'ALL' || user.role == selectedRole;
      
      return matchesSearch && matchesRole;
    }).toList();
  }
  
  final List<String> roleOptions = ['ALL', 'SUPER_ADMIN', 'CLIENT', 'CLIENT_USER'];
  
  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }
  
  Future<void> fetchUsers({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage.value = 1;
        _users.clear();
      }
      
      _isLoading.value = true;
      
      final clientId = _authService.isClient() || _authService.isClientUser() 
          ? _authService.clientId 
          : null;
      
      await _userService.fetchUsers(
        page: _currentPage.value,
        limit: 20,
        clientId: clientId,
      );
      
      _users.addAll(_userService.users);
      _currentPage.value++;
      _hasMoreData.value = _userService.hasMoreData;
      
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  void onSearchChanged(String query) {
    _searchQuery.value = query;
  }
  
  void onRoleFilterChanged(String role) {
    _selectedRole.value = role;
  }
  
  Future<void> refreshUsers() async {
    await fetchUsers(refresh: true);
  }
  
  Future<void> loadMoreUsers() async {
    if (hasMoreData && !isLoading) {
      await fetchUsers();
    }
  }
  
  Future<void> toggleUserStatus(UserModel user) async {
    try {
      final updatedUser = await _userService.toggleUserStatus(
        user.id, 
        !user.isActive,
      );
      
      if (updatedUser != null) {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user status: $e');
    }
  }
  
  Future<void> deleteUser(UserModel user) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${user.fullName}?'),
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
      
      if (confirmed == true) {
        final success = await _userService.deleteUser(user.id);
        if (success) {
          _users.removeWhere((u) => u.id == user.id);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user: $e');
    }
  }
  
  void goToUserDetail(UserModel user) {
    Get.toNamed('/user-detail', arguments: user);
  }
  
  void goToCreateUser() {
    Get.toNamed('/user-detail');
  }
  
  bool canManageUser(UserModel user) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;
    
    // Super admin can manage everyone except other super admins
    if (_authService.isSuperAdmin()) {
      return user.role != 'SUPER_ADMIN' || user.id == currentUser.id;
    }
    
    // Client can manage client users in their organization
    if (_authService.isClient()) {
      return user.role == 'CLIENT_USER' && user.clientId == currentUser.clientId;
    }
    
    // Client users can only manage themselves
    return user.id == currentUser.id;
  }
  
  String getUserRoleBadgeText(String role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return 'Super Admin';
      case 'CLIENT':
        return 'Client';
      case 'CLIENT_USER':
        return 'User';
      default:
        return role;
    }
  }
  
  Color getUserRoleBadgeColor(String role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return Get.theme.colorScheme.error;
      case 'CLIENT':
        return Get.theme.colorScheme.primary;
      case 'CLIENT_USER':
        return Get.theme.colorScheme.secondary;
      default:
        return Get.theme.colorScheme.outline;
    }
  }
}
