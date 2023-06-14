import 'dart:convert';

class JatahCutiTahunanModel {
  String? userId;
  String? name;
  String? year;
  int? annualLeave;

  JatahCutiTahunanModel({
    this.userId,
    this.name,
    this.year,
    this.annualLeave,
  });

  factory JatahCutiTahunanModel.fromJson(Map<String, dynamic> json) {
    return JatahCutiTahunanModel(
      userId: json['user_id'],
      name: json['name'],
      year: json['year'],
      annualLeave: json['annual_leave'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['name'] = name;
    data['year'] = year;
    data['annual_leave'] = annualLeave;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
