import 'user_model.dart';

class AuthModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final int expiresIn;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresIn,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: UserModel.fromJson(json['user']),
      expiresIn: json['expiresIn'] ?? 3600,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'expiresIn': expiresIn,
    };
  }
}

class AuthResult {
  final bool isSuccess;
  final String? message;
  final String? error;
  final UserModel? user;
  final String? token;

  AuthResult({
    required this.isSuccess,
    this.message,
    this.error,
    this.user,
    this.token,
  });

  factory AuthResult.success({String? message, UserModel? user, String? token}) {
    return AuthResult(
      isSuccess: true,
      message: message,
      user: user,
      token: token,
    );
  }

  factory AuthResult.failure({String? message, String? error}) {
    return AuthResult(
      isSuccess: false,
      message: message,
      error: error,
    );
  }
}
