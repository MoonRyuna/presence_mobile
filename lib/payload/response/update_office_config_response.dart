import 'dart:convert';

import 'package:presence_alpha/model/office_config_model.dart';
import 'package:presence_alpha/payload/response/base_response.dart';

class UpdateOfficeConfigResponse extends BaseResponse {
  final OfficeConfigModel? data;

  UpdateOfficeConfigResponse({
    required bool status,
    required String message,
    this.data,
  }) : super(status: status, message: message);

  factory UpdateOfficeConfigResponse.fromJson(Map<String, dynamic> json) {
    return UpdateOfficeConfigResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? OfficeConfigModel.fromJson(json['data'])
          : null,
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
