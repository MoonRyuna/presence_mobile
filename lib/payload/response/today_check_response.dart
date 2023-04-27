import 'dart:convert';

import 'package:presence_alpha/payload/data/today_check_data.dart';
import 'package:presence_alpha/payload/response/base_response.dart';

class TodayCheckResponse extends BaseResponse {
  final TodayCheckData? data;

  TodayCheckResponse({
    required bool status,
    required String message,
    this.data,
  }) : super(status: status, message: message);

  factory TodayCheckResponse.fromJson(Map<String, dynamic> json) {
    return TodayCheckResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? TodayCheckData.fromJson(json['data']) : null,
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
    return 'TodayCheckResponse{ status: $status, message: $message, data: $data }';
  }

  @override
  String toJsonString() {
    return jsonEncode(toJson());
  }
}
