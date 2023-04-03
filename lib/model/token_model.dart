import 'dart:convert';

class TokenModel {
  String? token;

  TokenModel({
    this.token,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    return data;
  }

  String toPlain() {
    return 'TokenModel{ token: $token }';
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
