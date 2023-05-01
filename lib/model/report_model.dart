import 'dart:convert';

import 'package:presence_alpha/model/user_model.dart';

class ReportModel {
  String? id;
  String? title;
  String? startDate;
  String? endDate;
  String? totalEmployee;
  String? generatedBy;
  String? generatedAt;
  UserModel? generater;

  ReportModel({
    this.id,
    this.title,
    this.startDate,
    this.endDate,
    this.totalEmployee,
    this.generatedBy,
    this.generatedAt,
    this.generater,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      title: json['title'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      totalEmployee: json['total_employee'],
      generatedBy: json['generated_by'],
      generatedAt: json['generated_at'],
      generater: json['generater'] != null
          ? UserModel.fromJson(json['generater'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['total_employee'] = totalEmployee;
    data['generated_by'] = generatedBy;
    data['generated_at'] = generatedAt;
    data['generater'] = generater != null ? generater!.toJson() : null;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
