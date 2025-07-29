// import 'package:get/get.dart';
// import '../models/user_model.dart';
// import '../models/subscription_model.dart';
// import 'api_service.dart';

// class UserService extends GetxService {
//   final ApiService _apiService = Get.find<ApiService>();
  
//   final _users = <UserModel>[].obs;
//   final _isLoading = false.obs;
//   final _currentPage = 1.obs;
//   final _totalPages = 1.obs;
//   final _hasMoreData = true.obs;
  
//   List<UserModel> get users => _users;
//   bool get isLoading => _isLoading.value;
//   int get currentPage => _currentPage.value;
//   int get totalPages => _totalPages.value;
//   bool get hasMoreData => _hasMoreData.value;
  
//   Future<void> fetchUsers({
//     int page = 1,
//     int limit = 10,
//     String? search,
//     String? role,
//     String? clientId,
//     bool refresh = false,
//   }) async {
//     try {
//       if (refresh) {
//         _users.clear();
//         _currentPage.value = 1;
//         _hasMoreData.value = true;
//       }
      
//       _isLoading.value = true;
      
//       final queryParams = <String, dynamic>{
//         'page': page,
//         'limit': limit,
//       };
      
//       if (search != null && search.isNotEmpty) {
//         queryParams['search'] = search;
//       }
//       if (role != null && role.isNotEmpty) {
//         queryParams['role'] = role;
//       }
//       if (clientId != null && clientId.isNotEmpty) {
//         queryParams['clientId'] = clientId;
//       }
      
//       final response = await _apiService.get('/users', queryParameters: queryParams);
      
//       if (response.statusCode == 200) {
//         final data = response.data;
//         final usersList = (data['data'] as List)
//             .map((user) => UserModel.fromJson(user))
//             .toList();
        
//         if (refresh || page == 1) {
//           _users.value = usersList;
//         } else {
//           _users.addAll(usersList);
//         }
        
//         final meta = data['meta'];
//         _currentPage.value = meta['page'];
//         _totalPages.value = meta['totalPages'];
//         _hasMoreData.value = _currentPage.value < _totalPages.value;
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to fetch users: $e');
//     } finally {
//       _isLoading.value = false;
//     }
//   }
  
//   Future<UserModel?> getUserById(String id) async {
//     try {
//       final response = await _apiService.get('/users/$id');
      
//       if (response.isSuccessful) {
//         return UserModel.fromJson(response.data);
//       }
//       return null;
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to fetch user: $e');
//       return null;
//     }
//   }
  
//   Future<bool> createUser(Map<String, dynamic> userData) async {
//     try {
//       final response = await _apiService.post('/users', userData);
      
//       if (response.isSuccessful) {
//         final newUser = UserModel.fromJson(response.data['user']);
//         _users.insert(0, newUser);
//         Get.snackbar('Success', 'User created successfully');
//         return true;
//       } else {
//         Get.snackbar('Error', response.message ?? 'Failed to create user');
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to create user: $e');
//       return false;
//     }
//   }
  
//   Future<bool> updateUser(String id, Map<String, dynamic> userData) async {
//     try {
//       final response = await _apiService.put('/users/$id', userData);
      
//       if (response.isSuccessful) {
//         final updatedUser = UserModel.fromJson(response.data);
//         final index = _users.indexWhere((user) => user.id == id);
//         if (index != -1) {
//           _users[index] = updatedUser;
//         }
//         Get.snackbar('Success', 'User updated successfully');
//         return true;
//       } else {
//         Get.snackbar('Error', response.message ?? 'Failed to update user');
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to update user: $e');
//       return false;
//     }
//   }
  
//   Future<bool> deleteUser(String id) async {
//     try {
//       final response = await _apiService.delete('/users/$id');
      
//       if (response.isSuccessful) {
//         _users.removeWhere((user) => user.id == id);
//         Get.snackbar('Success', 'User deleted successfully');
//         return true;
//       } else {
//         Get.snackbar('Error', response.message ?? 'Failed to delete user');
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to delete user: $e');
//       return false;
//     }
//   }
  
//   Future<List<UserSubscription>> getUserSubscriptions(String userId) async {
//     try {
//       final response = await _apiService.get('/subscriptions', 
//           queryParameters: {'userId': userId});
      
//       if (response.isSuccessful) {
//         final data = response.data;
//         return (data['data'] as List)
//             .map((sub) => UserSubscription.fromJson(sub))
//             .toList();
//       }
//       return [];
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to fetch user subscriptions: $e');
//       return [];
//     }
//   }
  
//   void loadMoreUsers({
//     String? search,
//     String? role,
//     String? clientId,
//   }) {
//     if (_hasMoreData.value && !_isLoading.value) {
//       fetchUsers(
//         page: _currentPage.value + 1,
//         search: search,
//         role: role,
//         clientId: clientId,
//       );
//     }
//   }
  
//   void refreshUsers({
//     String? search,
//     String? role,
//     String? clientId,
//   }) {
//     fetchUsers(
//       refresh: true,
//       search: search,
//       role: role,
//       clientId: clientId,
//     );
//   }
// }
