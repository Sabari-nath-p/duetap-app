import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final storage = GetStorage();
  
  final currentPage = 0.obs;
  final isLastPage = false.obs;
  
  final List<OnboardingPage> onboardingPages = [
    OnboardingPage(
      icon: Icons.notifications_active,
      title: 'Smart Notifications',
      description: 'Send automated payment reminders and custom notifications to your customers via WhatsApp and Email.',
    ),
    OnboardingPage(
      icon: Icons.payment,
      title: 'Payment Management',
      description: 'Manage subscriptions, track payments, and handle recurring billing with integrated payment gateways.',
    ),
    OnboardingPage(
      icon: Icons.analytics,
      title: 'Analytics & Reports',
      description: 'Get detailed insights about your notifications, payments, and customer engagement.',
    ),
    OnboardingPage(
      icon: Icons.people,
      title: 'Multi-tenant Support',
      description: 'Manage multiple clients and their users with role-based access control and permissions.',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _checkIfLastPage();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    _checkIfLastPage();
  }

  void _checkIfLastPage() {
    isLastPage.value = currentPage.value == onboardingPages.length - 1;
  }

  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void finishOnboarding() {
    storage.write('onboarding_completed', true);
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
