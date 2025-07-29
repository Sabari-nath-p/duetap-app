import 'user_model.dart';
import 'subscription_model.dart';
import 'client_model.dart';

class NotificationTemplate {
  final String id;
  final String name;
  final String type;
  final String channel;
  final String? subject;
  final String content;
  final List<String> variables;
  final bool isActive;
  final String clientId;
  final bool enablePaymentReminders;
  final List<int> reminderDays;
  final bool includePaymentLink;
  final bool escalationTemplate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Client? client;

  NotificationTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.channel,
    this.subject,
    required this.content,
    required this.variables,
    required this.isActive,
    required this.clientId,
    required this.enablePaymentReminders,
    required this.reminderDays,
    required this.includePaymentLink,
    required this.escalationTemplate,
    required this.createdAt,
    required this.updatedAt,
    this.client,
  });

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) {
    return NotificationTemplate(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      channel: json['channel'],
      subject: json['subject'],
      content: json['content'],
      variables: List<String>.from(json['variables'] ?? []),
      isActive: json['isActive'] ?? true,
      clientId: json['clientId'],
      enablePaymentReminders: json['enablePaymentReminders'] ?? false,
      reminderDays: List<int>.from(json['reminderDays'] ?? []),
      includePaymentLink: json['includePaymentLink'] ?? false,
      escalationTemplate: json['escalationTemplate'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'channel': channel,
      'subject': subject,
      'content': content,
      'variables': variables,
      'isActive': isActive,
      'clientId': clientId,
      'enablePaymentReminders': enablePaymentReminders,
      'reminderDays': reminderDays,
      'includePaymentLink': includePaymentLink,
      'escalationTemplate': escalationTemplate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'client': client?.toJson(),
    };
  }
}

class NotificationModel {
  final String id;
  final String templateId;
  final String userId;
  final String? userSubscriptionId;
  final String channel;
  final String recipient;
  final String? subject;
  final String content;
  final String status;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final NotificationTemplate? template;
  final UserModel? user;
  final UserSubscription? userSubscription;

  NotificationModel({
    required this.id,
    required this.templateId,
    required this.userId,
    this.userSubscriptionId,
    required this.channel,
    required this.recipient,
    this.subject,
    required this.content,
    required this.status,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.errorMessage,
    this.metadata,
    required this.createdAt,
    this.template,
    this.user,
    this.userSubscription,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      templateId: json['templateId'],
      userId: json['userId'],
      userSubscriptionId: json['userSubscriptionId'],
      channel: json['channel'],
      recipient: json['recipient'],
      subject: json['subject'],
      content: json['content'],
      status: json['status'],
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      errorMessage: json['errorMessage'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      template: json['template'] != null 
          ? NotificationTemplate.fromJson(json['template']) 
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      userSubscription: json['userSubscription'] != null 
          ? UserSubscription.fromJson(json['userSubscription']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'userId': userId,
      'userSubscriptionId': userSubscriptionId,
      'channel': channel,
      'recipient': recipient,
      'subject': subject,
      'content': content,
      'status': status,
      'sentAt': sentAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'template': template?.toJson(),
      'user': user?.toJson(),
      'userSubscription': userSubscription?.toJson(),
    };
  }
}
