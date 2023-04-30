import 'dart:convert';

class PresenceModel {
  BigInt? id;
  DateTime? checkIn;
  DateTime? checkOut;
  String? positionCheckIn;
  String? positionCheckOut;
  String? description;
  bool? late;
  double? lateAmount;
  bool? fullTime;
  double? remainingHour;
  bool? overtime;
  DateTime? overtimeStartAt;
  DateTime? overtimeEndAt;
  String? type;
  BigInt? userId;
  double? idleAmount;

  PresenceModel({
    this.id,
    this.checkIn,
    this.checkOut,
    this.positionCheckIn,
    this.positionCheckOut,
    this.description,
    this.late,
    this.lateAmount,
    this.fullTime,
    this.remainingHour,
    this.overtime,
    this.overtimeStartAt,
    this.overtimeEndAt,
    this.type,
    this.userId,
    this.idleAmount,
  });

  PresenceModel.fromJson(Map<String, dynamic> json) {
    id = BigInt.from(json['id']);
    checkIn = DateTime.parse(json['check_in']);
    checkOut = DateTime.parse(json['check_out']);
    positionCheckIn = json['position_check_in'];
    positionCheckOut = json['position_check_out'];
    description = json['description'];
    late = json['late'];
    lateAmount = json['late_amount'];
    fullTime = json['full_time'];
    remainingHour = json['remaining_hour'];
    overtime = json['overtime'];
    overtimeStartAt = DateTime.parse(json['overtime_start_at']);
    overtimeEndAt = DateTime.parse(json['overtime_end_at']);
    type = json['type'];
    userId = BigInt.from(json['user_id']);
    idleAmount = json['idle_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id.toString();
    data['check_in'] = checkIn?.toIso8601String();
    data['check_out'] = checkOut?.toIso8601String();
    data['position_check_in'] = positionCheckIn;
    data['position_check_out'] = positionCheckOut;
    data['description'] = description;
    data['late'] = late;
    data['late_amount'] = lateAmount;
    data['full_time'] = fullTime;
    data['remaining_hour'] = remainingHour;
    data['overtime'] = overtime;
    data['overtime_start_at'] = overtimeStartAt?.toIso8601String();
    data['overtime_end_at'] = overtimeEndAt?.toIso8601String();
    data['type'] = type;
    data['user_id'] = userId.toString();
    data['idle_amount'] = idleAmount;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
