import 'dart:convert';

import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/payload/response/base_response.dart';

class ChangePasswordResponse extends BaseResponse {
  final UserModel? data;

  ChangePasswordResponse({
    required bool status,
    required String message,
    this.data,
  }) : super(status: status, message: message);

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? UserModel.fromJson(json['data']) : null,
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

  @override
  String toJsonString() {
    return jsonEncode(toJson());
  }
}
