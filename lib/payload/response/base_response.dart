import 'dart:convert';

class BaseResponse {
  bool? status;
  String? message;

  BaseResponse({
    required this.status,
    required this.message,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      status: json['status'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
