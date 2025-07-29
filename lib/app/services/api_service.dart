import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:get_storage/get_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService extends getx.GetxService {
  late Dio _dio;
  final GetStorage _storage = GetStorage();
  
  static const String baseUrl = 'http://localhost:3000/api';
  
  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }
  
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptors
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
    
    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.read('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request
            final options = error.requestOptions;
            final token = _storage.read('access_token');
            options.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(options);
              handler.resolve(response);
              return;
            } catch (e) {
              // If retry fails, continue with error
            }
          }
        }
        handler.next(error);
      },
    ));
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _storage.read('refresh_token');
      if (refreshToken == null) return false;
      
      final response = await Dio().post(
        '$baseUrl/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        _storage.write('access_token', data['accessToken']);
        if (data['refreshToken'] != null) {
          _storage.write('refresh_token', data['refreshToken']);
        }
        return true;
      }
    } catch (e) {
      print('Token refresh failed: $e');
      // Clear stored tokens
      _storage.remove('access_token');
      _storage.remove('refresh_token');
      _storage.remove('user');
    }
    return false;
  }
  
  // HTTP Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException error) {
    String message;
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final errorData = error.response?.data;
        
        if (errorData is Map && errorData.containsKey('message')) {
          message = errorData['message'];
        } else {
          switch (statusCode) {
            case 400:
              message = 'Bad request. Please check your input.';
              break;
            case 401:
              message = 'Unauthorized. Please login again.';
              break;
            case 403:
              message = 'Access forbidden.';
              break;
            case 404:
              message = 'Resource not found.';
              break;
            case 500:
              message = 'Internal server error. Please try again later.';
              break;
            default:
              message = 'Something went wrong. Please try again.';
          }
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.unknown:
      default:
        message = 'Network error. Please check your connection.';
        break;
    }
    
    return Exception(message);
  }
  
  // File upload method
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (data != null) ...data,
        fieldName: await MultipartFile.fromFile(filePath),
      });
      
      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}