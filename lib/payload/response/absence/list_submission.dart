import 'dart:convert';

import 'package:presence_alpha/model/submission_model.dart';
import 'package:presence_alpha/payload/response/base_response.dart';

class ListSubmissionResponse extends BaseResponse {
  final List<SubmissionModel>? data;

  ListSubmissionResponse(
      {required bool status, required String message, this.data})
      : super(status: status, message: message);

  factory ListSubmissionResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<SubmissionModel> dataList =
        list.map((i) => SubmissionModel.fromJson(i)).toList();

    return ListSubmissionResponse(
      status: json['status'],
      message: json['message'],
      data: dataList,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['data'] = this.data!.map((e) => e.toJson()).toList();
    return data;
  }

  @override
  String toJsonString() {
    return jsonEncode(toJson());
  }
}
