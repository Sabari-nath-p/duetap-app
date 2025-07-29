import 'user_model.dart';

class UserSubscription {
  final String id;
  final String userId;
  final String planName;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final String? razorpaySubscriptionId;
  final String? stripeSubscriptionId;
  final DateTime startDate;
  final DateTime? nextBillingDate;
  final DateTime? endDate;
  final String billingCycle;
  final bool isRecurring;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user;
  final List<Payment>? payments;

  UserSubscription({
    required this.id,
    required this.userId,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    this.razorpaySubscriptionId,
    this.stripeSubscriptionId,
    required this.startDate,
    this.nextBillingDate,
    this.endDate,
    required this.billingCycle,
    required this.isRecurring,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.payments,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      id: json['id'],
      userId: json['userId'],
      planName: json['planName'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      razorpaySubscriptionId: json['razorpaySubscriptionId'],
      stripeSubscriptionId: json['stripeSubscriptionId'],
      startDate: DateTime.parse(json['startDate']),
      nextBillingDate: json['nextBillingDate'] != null 
          ? DateTime.parse(json['nextBillingDate']) 
          : null,
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : null,
      billingCycle: json['billingCycle'],
      isRecurring: json['isRecurring'] ?? false,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      payments: json['payments'] != null 
          ? (json['payments'] as List).map((p) => Payment.fromJson(p)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'planName': planName,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      'razorpaySubscriptionId': razorpaySubscriptionId,
      'stripeSubscriptionId': stripeSubscriptionId,
      'startDate': startDate.toIso8601String(),
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'billingCycle': billingCycle,
      'isRecurring': isRecurring,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'payments': payments?.map((p) => p.toJson()).toList(),
    };
  }
}

class Payment {
  final String id;
  final String userSubscriptionId;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? stripePaymentIntentId;
  final DateTime? paymentDate;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserSubscription? userSubscription;

  Payment({
    required this.id,
    required this.userSubscriptionId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.stripePaymentIntentId,
    this.paymentDate,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.userSubscription,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userSubscriptionId: json['userSubscriptionId'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      razorpayPaymentId: json['razorpayPaymentId'],
      razorpayOrderId: json['razorpayOrderId'],
      stripePaymentIntentId: json['stripePaymentIntentId'],
      paymentDate: json['paymentDate'] != null 
          ? DateTime.parse(json['paymentDate']) 
          : null,
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userSubscription: json['userSubscription'] != null 
          ? UserSubscription.fromJson(json['userSubscription']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userSubscriptionId': userSubscriptionId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpayOrderId': razorpayOrderId,
      'stripePaymentIntentId': stripePaymentIntentId,
      'paymentDate': paymentDate?.toIso8601String(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userSubscription': userSubscription?.toJson(),
    };
  }
}
