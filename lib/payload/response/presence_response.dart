import 'dart:convert';

import 'package:presence_alpha/payload/response/base_response.dart';

class PresenceResponse extends BaseResponse {
  PresenceResponse({
    required bool status,
    required String message,
  }) : super(status: status, message: message);

  factory PresenceResponse.fromJson(Map<String, dynamic> json) {
    return PresenceResponse(
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

  String toPlain() {
    return 'PresenceResponse{ status: $status, message: $message }';
  }

  @override
  String toJsonString() {
    return jsonEncode(toJson());
  }
}
