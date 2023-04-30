import 'dart:convert';

class OvertimeModel {
  BigInt? id;
  BigInt? userId;
  DateTime? overtimeAt;
  String? overtimeStatus;
  String? desc;
  String? attachment;

  OvertimeModel({
    this.id,
    this.userId,
    this.overtimeAt,
    this.overtimeStatus,
    this.desc,
    this.attachment,
  });

  OvertimeModel.fromJson(Map<String, dynamic> json) {
    id = BigInt.from(json['id']);
    userId = BigInt.from(json['user_id']);
    overtimeAt = DateTime.parse(json['overtime_at']);
    overtimeStatus = json['overtime_status'];
    desc = json['desc'];
    attachment = json['attachment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id.toString();
    data['user_id'] = userId.toString();
    data['overtime_at'] = overtimeAt?.toIso8601String();
    data['overtime_status'] = overtimeStatus;
    data['desc'] = desc;
    data['attachment'] = attachment;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
