import 'dart:convert';

import 'package:presence_alpha/payload/response/base_response.dart';

class SubmissionResponse extends BaseResponse {
  SubmissionResponse({
    required bool status,
    required String message,
  }) : super(status: status, message: message);

  factory SubmissionResponse.fromJson(Map<String, dynamic> json) {
    return SubmissionResponse(
      status: json['status'],
      message: json['message'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    return data;
  }

  @override
  String toJsonString() {
    return jsonEncode(toJson());
  }
}
