import 'dart:convert';

class AbsenceModel {
  BigInt? id;
  BigInt? userId;
  DateTime? absenceAt;
  String? absenceStatus;
  BigInt? absenceTypeId;
  bool? cutAnnualLeave;
  String? desc;
  String? attachment;

  AbsenceModel({
    this.id,
    this.userId,
    this.absenceAt,
    this.absenceStatus,
    this.absenceTypeId,
    this.cutAnnualLeave,
    this.desc,
    this.attachment,
  });

  AbsenceModel.fromJson(Map<String, dynamic> json) {
    id = BigInt.from(json['id']);
    userId = BigInt.from(json['user_id']);
    absenceAt = DateTime.parse(json['absence_at']);
    absenceStatus = json['absence_status'];
    absenceTypeId = BigInt.from(json['absence_type_id']);
    cutAnnualLeave = json['cut_annual_leave'];
    desc = json['desc'];
    attachment = json['attachment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id.toString();
    data['user_id'] = userId.toString();
    data['absence_at'] = absenceAt?.toIso8601String();
    data['absence_status'] = absenceStatus;
    data['absence_type_id'] = absenceTypeId.toString();
    data['cut_annual_leave'] = cutAnnualLeave;
    data['desc'] = desc;
    data['attachment'] = attachment;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
