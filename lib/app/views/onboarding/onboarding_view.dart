import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../controllers/onboarding_controller.dart';
import '../../utils/theme.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.onboardingPages.length,
                itemBuilder: (context, index) {
                  final page = controller.onboardingPages[index];
                  return Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          page.icon,
                          size: 120.w,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 48.h),
                        Text(
                          page.title,
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 28.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          page.description,
                          style: AppTextStyles.body1.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 16.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Page indicators
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.onboardingPages.length,
                      (index) => Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: controller.currentPage.value == index ? 24.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: controller.currentPage.value == index
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  )),
                  SizedBox(height: 32.h),
                  // Action buttons
                  Row(
                    children: [
                      if (controller.currentPage.value > 0)
                        TextButton(
                          onPressed: controller.previousPage,
                          child: Text(
                            'Previous',
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Obx(() => ElevatedButton(
                        onPressed: controller.isLastPage.value
                            ? controller.finishOnboarding
                            : controller.nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32.w,
                            vertical: 16.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          controller.isLastPage.value ? 'Get Started' : 'Next',
                          style: AppTextStyles.body1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
