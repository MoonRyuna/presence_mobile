import 'dart:convert';

import 'package:presence_alpha/payload/data/upload_data.dart';
import 'package:presence_alpha/payload/response/base_response.dart';

class UploadResponse extends BaseResponse {
  final UploadData? data;

  UploadResponse({
    required bool status,
    required String message,
    this.data,
  }) : super(status: status, message: message);

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? UploadData.fromJson(json['data']) : null,
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
    return 'UploadResponse{ status: $status, message: $message }';
  }

  @override
  String toJsonString() {
    return jsonEncode(toJson());
  }
}
