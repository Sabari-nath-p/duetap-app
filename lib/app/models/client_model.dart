class Client {
  final String id;
  final String name;
  final String email;
  final String domain;
  final bool isActive;
  final String subscriptionPlan;
  final DateTime billingStartDate;
  final WhatsAppConfig? whatsappConfig;
  final EmailConfig? emailConfig;
  final PaymentConfig? paymentConfig;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ClientCounts? counts;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.domain,
    required this.isActive,
    required this.subscriptionPlan,
    required this.billingStartDate,
    this.whatsappConfig,
    this.emailConfig,
    this.paymentConfig,
    required this.createdAt,
    required this.updatedAt,
    this.counts,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      domain: json['domain'],
      isActive: json['isActive'],
      subscriptionPlan: json['subscriptionPlan'],
      billingStartDate: DateTime.parse(json['billingStartDate']),
      whatsappConfig: json['whatsappConfig'] != null 
          ? WhatsAppConfig.fromJson(json['whatsappConfig']) 
          : null,
      emailConfig: json['emailConfig'] != null 
          ? EmailConfig.fromJson(json['emailConfig']) 
          : null,
      paymentConfig: json['paymentConfig'] != null 
          ? PaymentConfig.fromJson(json['paymentConfig']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      counts: json['_count'] != null 
          ? ClientCounts.fromJson(json['_count']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'domain': domain,
      'isActive': isActive,
      'subscriptionPlan': subscriptionPlan,
      'billingStartDate': billingStartDate.toIso8601String(),
      'whatsappConfig': whatsappConfig?.toJson(),
      'emailConfig': emailConfig?.toJson(),
      'paymentConfig': paymentConfig?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '_count': counts?.toJson(),
    };
  }
}

class WhatsAppConfig {
  final String? accessToken;
  final String? phoneNumberId;
  final bool isConfigured;

  WhatsAppConfig({
    this.accessToken,
    this.phoneNumberId,
    required this.isConfigured,
  });

  factory WhatsAppConfig.fromJson(Map<String, dynamic> json) {
    return WhatsAppConfig(
      accessToken: json['accessToken'],
      phoneNumberId: json['phoneNumberId'],
      isConfigured: json['isConfigured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'phoneNumberId': phoneNumberId,
      'isConfigured': isConfigured,
    };
  }
}

class EmailConfig {
  final String? smtpHost;
  final int? smtpPort;
  final String? smtpUsername;
  final bool isConfigured;

  EmailConfig({
    this.smtpHost,
    this.smtpPort,
    this.smtpUsername,
    required this.isConfigured,
  });

  factory EmailConfig.fromJson(Map<String, dynamic> json) {
    return EmailConfig(
      smtpHost: json['smtpHost'],
      smtpPort: json['smtpPort'],
      smtpUsername: json['smtpUsername'],
      isConfigured: json['isConfigured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'smtpHost': smtpHost,
      'smtpPort': smtpPort,
      'smtpUsername': smtpUsername,
      'isConfigured': isConfigured,
    };
  }
}

class PaymentConfig {
  final RazorpayConfig? razorpay;
  final StripeConfig? stripe;

  PaymentConfig({
    this.razorpay,
    this.stripe,
  });

  factory PaymentConfig.fromJson(Map<String, dynamic> json) {
    return PaymentConfig(
      razorpay: json['razorpay'] != null 
          ? RazorpayConfig.fromJson(json['razorpay']) 
          : null,
      stripe: json['stripe'] != null 
          ? StripeConfig.fromJson(json['stripe']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'razorpay': razorpay?.toJson(),
      'stripe': stripe?.toJson(),
    };
  }
}

class RazorpayConfig {
  final String? keyId;
  final bool isConfigured;

  RazorpayConfig({
    this.keyId,
    required this.isConfigured,
  });

  factory RazorpayConfig.fromJson(Map<String, dynamic> json) {
    return RazorpayConfig(
      keyId: json['keyId'],
      isConfigured: json['isConfigured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyId': keyId,
      'isConfigured': isConfigured,
    };
  }
}

class StripeConfig {
  final String? publicKey;
  final bool isConfigured;

  StripeConfig({
    this.publicKey,
    required this.isConfigured,
  });

  factory StripeConfig.fromJson(Map<String, dynamic> json) {
    return StripeConfig(
      publicKey: json['publicKey'],
      isConfigured: json['isConfigured'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'publicKey': publicKey,
      'isConfigured': isConfigured,
    };
  }
}

class ClientCounts {
  final int users;
  final int templates;
  final int notifications;

  ClientCounts({
    required this.users,
    required this.templates,
    required this.notifications,
  });

  factory ClientCounts.fromJson(Map<String, dynamic> json) {
    return ClientCounts(
      users: json['users'] ?? 0,
      templates: json['templates'] ?? 0,
      notifications: json['notifications'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users,
      'templates': templates,
      'notifications': notifications,
    };
  }
}
