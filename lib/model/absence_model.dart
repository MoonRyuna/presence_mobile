import 'dart:convert';

import 'package:presence_alpha/model/absence_type_model.dart';
import 'package:presence_alpha/model/user_model.dart';

class AbsenceModel {
  String? id;
  String? userId;
  String? absenceAt;
  String? absenceStatus;
  String? absenceTypeId;
  bool? cutAnnualLeave;
  String? desc;
  String? attachment;
  final AbsenceTypeModel? absenceType;
  final UserModel? user;

  AbsenceModel({
    this.id,
    this.userId,
    this.absenceAt,
    this.absenceStatus,
    this.absenceTypeId,
    this.cutAnnualLeave,
    this.desc,
    this.attachment,
    this.absenceType,
    this.user,
  });

  factory AbsenceModel.fromJson(Map<String, dynamic> json) {
    return AbsenceModel(
      id: json['id'],
      userId: json['user_id'],
      absenceAt: json['absence_at'],
      absenceStatus: json['absence_status'],
      absenceTypeId: json['absence_type_id'],
      cutAnnualLeave: json['cut_annual_leave'],
      desc: json['desc'],
      attachment: json['attachment'],
      absenceType: json['absence_type'] != null
          ? AbsenceTypeModel.fromJson(json['absence_type'])
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['absence_at'] = absenceAt;
    data['absence_status'] = absenceStatus;
    data['absence_type_id'] = absenceTypeId;
    data['cut_annual_leave'] = cutAnnualLeave;
    data['desc'] = desc;
    data['attachment'] = attachment;
    data['absence_type'] = absenceType != null ? absenceType!.toJson() : null;
    data['user'] = user != null ? user!.toJson() : null;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
