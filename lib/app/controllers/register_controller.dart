import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  final _isLoading = false.obs;
  final _isPasswordHidden = true.obs;
  final _isConfirmPasswordHidden = true.obs;
  
  bool get isLoading => _isLoading.value;
  RxBool get isPasswordHidden => _isPasswordHidden;
  RxBool get isConfirmPasswordHidden => _isConfirmPasswordHidden;
  
  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
  
  void togglePasswordVisibility() {
    _isPasswordHidden.value = !_isPasswordHidden.value;
  }
  
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordHidden.value = !_isConfirmPasswordHidden.value;
  }
  
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
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
  
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    
    try {
      _isLoading.value = true;
      
      final success = await _authService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      if (success) {
        Get.offAllNamed('/dashboard');
        Get.snackbar('Success', 'Account created successfully!');
      } else {
        Get.snackbar('Error', 'Failed to create account');
      }
    } catch (e) {
      Get.snackbar('Error', 'Registration failed: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  void goToLogin() {
    Get.back();
  }
}
