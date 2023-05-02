import 'dart:convert';

import 'package:presence_alpha/model/user_model.dart';

class OvertimeModel {
  int? id;
  String? userId;
  String? overtimeAt;
  String? overtimeStatus;
  String? desc;
  String? attachment;
  final UserModel? user;

  OvertimeModel({
    this.id,
    this.userId,
    this.overtimeAt,
    this.overtimeStatus,
    this.desc,
    this.attachment,
    this.user,
  });

  factory OvertimeModel.fromJson(Map<String, dynamic> json) {
    return OvertimeModel(
      id: json['id'],
      userId: json['user_id'],
      overtimeAt: json['overtime_at'],
      overtimeStatus: json['overtime_status'],
      desc: json['desc'],
      attachment: json['attachment'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['overtime_at'] = overtimeAt;
    data['overtime_status'] = overtimeStatus;
    data['desc'] = desc;
    data['attachment'] = attachment;
    data['user'] = user != null ? user!.toJson() : null;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
