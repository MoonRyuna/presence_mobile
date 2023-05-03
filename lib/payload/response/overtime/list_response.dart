import 'dart:convert';

import 'package:presence_alpha/model/overtime_model.dart';
import 'package:presence_alpha/payload/response/base_response.dart';

class ListResponse extends BaseResponse {
  final ListDataResponse? data;

  ListResponse({
    required bool status,
    required String message,
    this.data,
  }) : super(status: status, message: message);

  factory ListResponse.fromJson(Map<String, dynamic> json) {
    return ListResponse(
      status: json['status'],
      message: json['message'],
      data:
          json['data'] != null ? ListDataResponse.fromJson(json['data']) : null,
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

class ListDataResponse {
  final int total;
  final int currentPage;
  final int nextPage;
  final int prevPage;
  final int limit;
  final List<OvertimeModel> result;

  ListDataResponse({
    required this.total,
    required this.currentPage,
    required this.nextPage,
    required this.prevPage,
    required this.limit,
    required this.result,
  });

  factory ListDataResponse.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<OvertimeModel> dataList =
        list.map((i) => OvertimeModel.fromJson(i)).toList();

    return ListDataResponse(
      total: json['total'],
      currentPage: json['current_page'],
      nextPage: json['next_page'],
      prevPage: json['prev_page'],
      limit: json['limit'],
      result: dataList,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['current_page'] = currentPage;
    data['next_page'] = nextPage;
    data['prev_page'] = prevPage;
    data['limit'] = limit;
    data['result'] = result.map((e) => e.toJson()).toList();
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
