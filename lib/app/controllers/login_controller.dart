import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  final _isLoading = false.obs;
  final _isPasswordHidden = true.obs;
  
  bool get isLoading => _isLoading.value;
  RxBool get isPasswordHidden => _isPasswordHidden;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  void togglePasswordVisibility() {
    _isPasswordHidden.value = !_isPasswordHidden.value;
  }
  
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  
  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      _isLoading.value = true;
      
      final success = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );
      
      if (success) {
        Get.offAllNamed('/dashboard');
      } else {
        Get.snackbar('Error', 'Invalid credentials');
      }
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  void goToRegister() {
    Get.toNamed('/register');
  }
  
  void goToForgotPassword() {
    Get.toNamed('/forgot-password');
  }
}