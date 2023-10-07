import 'dart:convert';

class UserAuthModel {
  String? username;
  String? password;
  String? deviceUnique;

  UserAuthModel({
    this.username,
    this.password,
    this.deviceUnique,
  });

  factory UserAuthModel.fromJson(Map<String, dynamic> json) {
    return UserAuthModel(
      username: json['username'],
      password: json['password'],
      deviceUnique: json['device_unique'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['password'] = password;
    data['device_unique'] = deviceUnique;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
