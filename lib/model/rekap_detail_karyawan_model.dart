import 'dart:convert';

class RekapDetailKaryawanModel {
  String? userId;
  String? date;
  String? description;

  RekapDetailKaryawanModel({
    this.userId,
    this.date,
    this.description,
  });

  factory RekapDetailKaryawanModel.fromJson(Map<String, dynamic> json) {
    return RekapDetailKaryawanModel(
      userId: json['user_id'],
      date: json['date'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['date'] = date;
    data['description'] = description;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
