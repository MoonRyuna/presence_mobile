import 'dart:convert';

import 'package:presence_alpha/model/report_model.dart';
import 'package:presence_alpha/model/user_model.dart';

class ReportDetailModel {
  String? id;
  String? userId;
  String? reportId;
  String? date;
  String? description;
  UserModel? user;
  ReportModel? report;

  ReportDetailModel({
    this.id,
    this.userId,
    this.reportId,
    this.date,
    this.description,
    this.user,
    this.report,
  });

  factory ReportDetailModel.fromJson(Map<String, dynamic> json) {
    return ReportDetailModel(
      id: json['id'],
      userId: json['user_id'],
      reportId: json['report_id'],
      date: json['date'],
      description: json['description'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      report:
          json['report'] != null ? ReportModel.fromJson(json['report']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['report_id'] = reportId;
    data['date'] = date;
    data['description'] = description;
    data['user'] = user != null ? user!.toJson() : null;
    data['report'] = report != null ? report!.toJson() : null;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
