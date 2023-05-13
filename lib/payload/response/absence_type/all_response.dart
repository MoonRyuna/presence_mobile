import 'dart:convert';

import 'package:presence_alpha/model/absence_type_model.dart';
import 'package:presence_alpha/payload/response/base_response.dart';

class AllResponse extends BaseResponse {
  final List<AbsenceTypeModel>? data;

  AllResponse({required bool status, required String message, this.data})
      : super(status: status, message: message);

  factory AllResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<AbsenceTypeModel> dataList =
        list.map((i) => AbsenceTypeModel.fromJson(i)).toList();

    return AllResponse(
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
