import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();
  
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoggedIn = false.obs;
  final RxBool _isLoading = false.obs;
  
  UserModel? get currentUser => _currentUser.value;
  bool get isLoggedIn => _isLoggedIn.value;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }
  
  void _checkAuthStatus() {
    final token = _storage.read('access_token');
    final userData = _storage.read('user');
    
    if (token != null && userData != null) {
      _currentUser.value = UserModel.fromJson(userData);
      _isLoggedIn.value = true;
    }
  }
  
  Future<bool> login(String email, String password) async {
    try {
      _isLoading.value = true;
      
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Store tokens
        _storage.write('access_token', data['accessToken']);
        _storage.write('refresh_token', data['refreshToken']);
        
        // Store user data
        final user = UserModel.fromJson(data['user']);
        _storage.write('user', user.toJson());
        
        _currentUser.value = user;
        _isLoggedIn.value = true;
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? clientId,
  }) async {
    try {
      _isLoading.value = true;
      
      final response = await _apiService.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        if (clientId != null) 'clientId': clientId,
      });
      
      if (response.statusCode == 201) {
        final data = response.data;
        
        // Store tokens
        _storage.write('access_token', data['accessToken']);
        _storage.write('refresh_token', data['refreshToken']);
        
        // Store user data
        final user = UserModel.fromJson(data['user']);
        _storage.write('user', user.toJson());
        
        _currentUser.value = user;
        _isLoggedIn.value = true;
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    try {
      // Call logout endpoint to invalidate tokens on server
      await _apiService.post('/auth/logout');
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Clear local data regardless of server response
      _storage.remove('access_token');
      _storage.remove('refresh_token');
      _storage.remove('user');
      
      _currentUser.value = null;
      _isLoggedIn.value = false;
      
      // Navigate to login
      Get.offAllNamed('/login');
    }
  }
  
  Future<bool> forgotPassword(String email) async {
    try {
      _isLoading.value = true;
      
      final response = await _apiService.post('/auth/forgot-password', data: {
        'email': email,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      print('Forgot password error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;
      
      final response = await _apiService.post('/auth/reset-password', data: {
        'token': token,
        'password': newPassword,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;
      
      final response = await _apiService.put('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      
      return response.statusCode == 200;
    } catch (e) {
      print('Change password error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? phone,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      _isLoading.value = true;
      
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (preferences != null) data['preferences'] = preferences;
      
      final response = await _apiService.put('/auth/profile', data: data);
      
      if (response.statusCode == 200) {
        // Update stored user data
        final updatedUser = UserModel.fromJson(response.data['user']);
        _storage.write('user', updatedUser.toJson());
        _currentUser.value = updatedUser;
        return true;
      }
      
      return false;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<bool> refreshToken() async {
    try {
      final refreshToken = _storage.read('refresh_token');
      if (refreshToken == null) return false;
      
      final response = await _apiService.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        _storage.write('access_token', data['accessToken']);
        
        if (data['refreshToken'] != null) {
          _storage.write('refresh_token', data['refreshToken']);
        }
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Refresh token error: $e');
      await logout();
      return false;
    }
  }
  
  // Role and permission checks
  bool hasRole(String role) {
    return _currentUser.value?.role == role;
  }
  
  bool isSuperAdmin() => hasRole('SUPER_ADMIN');
  bool isClient() => hasRole('CLIENT');
  bool isClientUser() => hasRole('CLIENT_USER');
  
  String? get clientId => _currentUser.value?.clientId;
  String? get userId => _currentUser.value?.id;
}