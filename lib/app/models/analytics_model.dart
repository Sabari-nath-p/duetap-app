class Analytics {
  final AnalyticsSummary summary;
  final AnalyticsCharts charts;
  final List<Activity> recentActivities;

  Analytics({
    required this.summary,
    required this.charts,
    required this.recentActivities,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) {
    return Analytics(
      summary: AnalyticsSummary.fromJson(json['summary']),
      charts: AnalyticsCharts.fromJson(json['charts']),
      recentActivities: (json['recentActivities'] as List)
          .map((activity) => Activity.fromJson(activity))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'charts': charts.toJson(),
      'recentActivities': recentActivities.map((a) => a.toJson()).toList(),
    };
  }
}

class AnalyticsSummary {
  final int totalUsers;
  final int activeSubscriptions;
  final double totalRevenue;
  final int notificationsSent;
  final double userGrowth;
  final double revenueGrowth;
  final double notificationGrowth;

  AnalyticsSummary({
    required this.totalUsers,
    required this.activeSubscriptions,
    required this.totalRevenue,
    required this.notificationsSent,
    required this.userGrowth,
    required this.revenueGrowth,
    required this.notificationGrowth,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalUsers: json['totalUsers'] ?? 0,
      activeSubscriptions: json['activeSubscriptions'] ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      notificationsSent: json['notificationsSent'] ?? 0,
      userGrowth: (json['userGrowth'] as num?)?.toDouble() ?? 0.0,
      revenueGrowth: (json['revenueGrowth'] as num?)?.toDouble() ?? 0.0,
      notificationGrowth: (json['notificationGrowth'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeSubscriptions': activeSubscriptions,
      'totalRevenue': totalRevenue,
      'notificationsSent': notificationsSent,
      'userGrowth': userGrowth,
      'revenueGrowth': revenueGrowth,
      'notificationGrowth': notificationGrowth,
    };
  }
}

class AnalyticsCharts {
  final List<RevenueData> revenueOverTime;
  final List<ChannelData> notificationChannels;
  final List<PaymentMethodData> paymentMethods;

  AnalyticsCharts({
    required this.revenueOverTime,
    required this.notificationChannels,
    required this.paymentMethods,
  });

  factory AnalyticsCharts.fromJson(Map<String, dynamic> json) {
    return AnalyticsCharts(
      revenueOverTime: (json['revenueOverTime'] as List)
          .map((data) => RevenueData.fromJson(data))
          .toList(),
      notificationChannels: (json['notificationChannels'] as List)
          .map((data) => ChannelData.fromJson(data))
          .toList(),
      paymentMethods: (json['paymentMethods'] as List)
          .map((data) => PaymentMethodData.fromJson(data))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenueOverTime': revenueOverTime.map((r) => r.toJson()).toList(),
      'notificationChannels': notificationChannels.map((n) => n.toJson()).toList(),
      'paymentMethods': paymentMethods.map((p) => p.toJson()).toList(),
    };
  }
}

class RevenueData {
  final String date;
  final double revenue;
  final int subscriptions;

  RevenueData({
    required this.date,
    required this.revenue,
    required this.subscriptions,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      date: json['date'],
      revenue: (json['revenue'] as num).toDouble(),
      subscriptions: json['subscriptions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'revenue': revenue,
      'subscriptions': subscriptions,
    };
  }
}

class ChannelData {
  final String channel;
  final int count;
  final double percentage;

  ChannelData({
    required this.channel,
    required this.count,
    required this.percentage,
  });

  factory ChannelData.fromJson(Map<String, dynamic> json) {
    return ChannelData(
      channel: json['channel'],
      count: json['count'] ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channel': channel,
      'count': count,
      'percentage': percentage,
    };
  }
}

class PaymentMethodData {
  final String method;
  final int count;
  final double amount;

  PaymentMethodData({
    required this.method,
    required this.count,
    required this.amount,
  });

  factory PaymentMethodData.fromJson(Map<String, dynamic> json) {
    return PaymentMethodData(
      method: json['method'],
      count: json['count'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'count': count,
      'amount': amount,
    };
  }
}

class Activity {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Activity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}
