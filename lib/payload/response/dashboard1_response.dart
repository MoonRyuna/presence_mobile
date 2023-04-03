import 'dart:convert';

import 'package:presence_alpha/payload/data/dashboard1_data.dart';
import 'package:presence_alpha/payload/response/base_response.dart';

class Dashboard1Response extends BaseResponse {
  final Dashboard1Data? data;

  Dashboard1Response({
    required bool status,
    required String message,
    this.data,
  }) : super(status: status, message: message);

  factory Dashboard1Response.fromJson(Map<String, dynamic> json) {
    return Dashboard1Response(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? Dashboard1Data.fromJson(json['data']) : null,
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

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
