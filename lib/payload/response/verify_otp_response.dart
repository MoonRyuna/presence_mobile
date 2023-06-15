import 'dart:convert';

import 'package:presence_alpha/payload/data/verify_otp_data.dart';
import 'package:presence_alpha/payload/response/base_response.dart';

class VerifyOTPResponse extends BaseResponse {
  final VerifyOTPData? data;

  VerifyOTPResponse({
    required bool status,
    required String message,
    this.data,
  }) : super(status: status, message: message);

  factory VerifyOTPResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOTPResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? VerifyOTPData.fromJson(json['data']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['data'] = this.data != null ? this.data!.toJson() : null;
    return data;
  }

  String toPlain() {
    return 'AuthResponse{ status: $status, message: $message, data: $data }';
  }

  @override
  String toJsonString() {
    return jsonEncode(toJson());
  }
}
