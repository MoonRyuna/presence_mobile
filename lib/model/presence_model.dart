import 'dart:convert';

import 'package:presence_alpha/model/user_model.dart';

class PresenceModel {
  int? id;
  String? checkIn;
  String? checkOut;
  String? positionCheckIn;
  String? positionCheckOut;
  String? description;
  bool? late;
  double? lateAmount;
  bool? fullTime;
  double? remainingHour;
  bool? overtime;
  String? overtimeStartAt;
  String? overtimeEndAt;
  String? type;
  String? userId;
  bool? idleAmount;
  final UserModel? user;

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
    this.user,
  });

  factory PresenceModel.fromJson(Map<String, dynamic> json) {
    return PresenceModel(
      id: json['id'],
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      positionCheckIn: json['position_check_in'],
      positionCheckOut: json['position_check_out'],
      description: json['description'],
      late: json['late'],
      lateAmount: json['late_amount'],
      fullTime: json['full_time'],
      remainingHour: json['remaining_hour'],
      overtime: json['overtime'],
      overtimeStartAt: json['overtime_start_at'],
      overtimeEndAt: json['overtime_end_at'],
      type: json['type'],
      userId: json['user_id'],
      idleAmount: json['idle_amount'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['check_in'] = checkIn;
    data['check_out'] = checkOut;
    data['position_check_in'] = positionCheckIn;
    data['position_check_out'] = positionCheckOut;
    data['description'] = description;
    data['late'] = late;
    data['late_amount'] = lateAmount;
    data['full_time'] = fullTime;
    data['remaining_hour'] = remainingHour;
    data['overtime'] = overtime;
    data['overtime_start_at'] = overtimeStartAt;
    data['overtime_end_at'] = overtimeEndAt;
    data['type'] = type;
    data['user_id'] = userId;
    data['idle_amount'] = idleAmount;
    data['user'] = user != null ? user!.toJson() : null;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
