import 'dart:convert';

import 'package:presence_alpha/payload/response/base_response.dart';

class DownloadResponse extends BaseResponse {
  final Data? data;

  DownloadResponse({
    required bool status,
    required String message,
    this.data,
  }) : super(status: status, message: message);

  factory DownloadResponse.fromJson(Map<String, dynamic> json) {
    return DownloadResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
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

class Data {
  final String? url;

  Data({
    this.url,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(url: json['url']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    return data;
  }
}
