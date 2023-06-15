import 'dart:convert';

class VerifyOTPData {
  String? userId;

  VerifyOTPData({
    this.userId,
  });

  factory VerifyOTPData.fromJson(Map<String, dynamic> json) {
    return VerifyOTPData(
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
