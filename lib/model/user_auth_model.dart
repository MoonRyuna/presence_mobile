import 'dart:convert';

class UserAuthModel {
  String? username;
  String? password;
  String? imei;

  UserAuthModel({
    this.username,
    this.password,
    this.imei,
  });

  factory UserAuthModel.fromJson(Map<String, dynamic> json) {
    return UserAuthModel(
      username: json['username'],
      password: json['password'],
      imei: json['imei'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['password'] = password;
    data['imei'] = imei;
    return data;
  }

  String toPlain() {
    return 'UserAuthModel{ username: $username, password: $password, imei: $imei }';
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
