import 'dart:convert';

class AuthData {
  String? token;
  String? accountType;

  AuthData({
    this.token,
    this.accountType,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'],
      accountType: json['account_type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['account_type'] = accountType;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
