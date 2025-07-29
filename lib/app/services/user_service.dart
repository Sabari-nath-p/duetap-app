import 'package:get/get.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  
  final _users = <UserModel>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 1.obs;
  final _totalPages = 1.obs;
  final _hasMoreData = true.obs;
  
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  int get totalPages => _totalPages.value;
  bool get hasMoreData => _hasMoreData.value;
  
  Future<void> fetchUsers({
    int page = 1,
    int limit = 10,
    String? search,
    String? role,
    String? clientId,
  }) async {
    try {
      _isLoading.value = true;
      
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (role != null && role.isNotEmpty) {
        queryParams['role'] = role;
      }
      if (clientId != null && clientId.isNotEmpty) {
        queryParams['clientId'] = clientId;
      }
      
      final response = await _apiService.get('/users', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final usersList = (data['users'] as List)
            .map((user) => UserModel.fromJson(user))
            .toList();
        
        if (page == 1) {
          _users.clear();
        }
        _users.addAll(usersList);
        
        _currentPage.value = data['currentPage'] ?? page;
        _totalPages.value = data['totalPages'] ?? 1;
        _hasMoreData.value = _currentPage.value < _totalPages.value;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch users: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<UserModel?> getUserById(String id) async {
    try {
      final response = await _apiService.get('/users/$id');
      
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user: $e');
    }
    return null;
  }
  
  Future<UserModel?> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post('/users', data: userData);
      
      if (response.statusCode == 201) {
        final user = UserModel.fromJson(response.data['user']);
        _users.add(user);
        return user;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create user: $e');
    }
    return null;
  }
  
  Future<UserModel?> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.put('/users/$id', data: userData);
      
      if (response.statusCode == 200) {
        final updatedUser = UserModel.fromJson(response.data['user']);
        final index = _users.indexWhere((user) => user.id == id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
        return updatedUser;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user: $e');
    }
    return null;
  }
  
  Future<bool> deleteUser(String id) async {
    try {
      final response = await _apiService.delete('/users/$id');
      
      if (response.statusCode == 200) {
        _users.removeWhere((user) => user.id == id);
        Get.snackbar('Success', 'User deleted successfully');
        return true;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user: $e');
    }
    return false;
  }
  
  Future<UserModel?> toggleUserStatus(String id, bool isActive) async {
    try {
      final response = await _apiService.put('/users/$id/status', data: {
        'isActive': isActive,
      });
      
      if (response.statusCode == 200) {
        final updatedUser = UserModel.fromJson(response.data['user']);
        final index = _users.indexWhere((user) => user.id == id);
        if (index != -1) {
          _users[index] = updatedUser;
        }
        return updatedUser;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user status: $e');
    }
    return null;
  }
  
  void refreshUsers() {
    fetchUsers(page: 1);
  }
  
  void loadMoreUsers() {
    if (hasMoreData && !isLoading) {
      fetchUsers(page: currentPage + 1);
    }
  }
  
  void clearUsers() {
    _users.clear();
    _currentPage.value = 1;
    _totalPages.value = 1;
    _hasMoreData.value = true;
  }
}
