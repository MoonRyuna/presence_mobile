import 'dart:convert';

import 'package:presence_alpha/model/date_range_model.dart';
import 'package:presence_alpha/model/rekap_detail_karyawan_model.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/payload/response/base_response.dart';

class RekapDetailKaryawanResponse extends BaseResponse {
  final DataResponse? data;

  RekapDetailKaryawanResponse({
    required bool status,
    required String message,
    this.data,
  }) : super(status: status, message: message);

  factory RekapDetailKaryawanResponse.fromJson(Map<String, dynamic> json) {
    return RekapDetailKaryawanResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? DataResponse.fromJson(json['data']) : null,
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

class DataResponse {
  final UserModel user;
  final DateRangeModel date;
  final List<RekapDetailKaryawanModel> list;

  DataResponse({
    required this.user,
    required this.date,
    required this.list,
  });

  factory DataResponse.fromJson(Map<String, dynamic> json) {
    var list = json['list'] as List;
    List<RekapDetailKaryawanModel> dataList =
        list.map((i) => RekapDetailKaryawanModel.fromJson(i)).toList();

    return DataResponse(
      user: UserModel.fromJson(json['user']),
      date: DateRangeModel.fromJson(json['date']),
      list: dataList,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user.toJson();
    data['date'] = date.toJson();
    data['list'] = list.map((e) => e.toJson()).toList();
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
