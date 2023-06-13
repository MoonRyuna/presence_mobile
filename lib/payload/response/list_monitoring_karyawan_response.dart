import 'dart:convert';

import 'package:presence_alpha/payload/response/base_response.dart';
import 'package:presence_alpha/payload/response/monitoring_karyawan_response.dart';

class ListMonitoringKaryawanResponse extends BaseResponse {
  final MonitoringKaryawanResponse? data;

  ListMonitoringKaryawanResponse({
    required bool status,
    required String message,
    this.data,
  }) : super(status: status, message: message);

  factory ListMonitoringKaryawanResponse.fromJson(Map<String, dynamic> json) {
    return ListMonitoringKaryawanResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? MonitoringKaryawanResponse.fromJson(json['data']) : null,
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
