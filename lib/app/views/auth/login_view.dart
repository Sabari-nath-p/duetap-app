import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';
import '../../utils/theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              // Logo and title
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.schedule_send,
                        color: Colors.white,
                        size: 40.w,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'ScheduRemind',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 32.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Smart notification & payment platform',
                      style: AppTextStyles.body2,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48.h),
              // Welcome text
              Text(
                'Welcome back!',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 24.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Sign in to your account',
                style: AppTextStyles.body2,
              ),
              SizedBox(height: 32.h),
              // Login form
              Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: controller.emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: controller.validateEmail,
                    ),
                    SizedBox(height: 16.h),
                    Obx(() => CustomTextField(
                      controller: controller.passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: controller.isPasswordHidden.value,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        onPressed: controller.togglePasswordVisibility,
                        icon: Icon(
                          controller.isPasswordHidden.value
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      validator: controller.validatePassword,
                    )),
                    SizedBox(height: 24.h),
                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed('/forgot-password'),
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Login button
                    Obx(() => CustomButton(
                      text: 'Sign In',
                      onPressed: controller.isLoading ? null : controller.login,
                      isLoading: controller.isLoading,
                    )),
                    SizedBox(height: 24.h),
                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.body2,
                        ),
                        TextButton(
                          onPressed: () => Get.toNamed('/register'),
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
