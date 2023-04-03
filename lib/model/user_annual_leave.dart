import 'dart:convert';

class UserAnnualLeaveModel {
  String? year;
  int? annualLeave;

  UserAnnualLeaveModel({
    this.year,
    this.annualLeave,
  });

  factory UserAnnualLeaveModel.fromJson(Map<String, dynamic> json) {
    return UserAnnualLeaveModel(
      annualLeave: json['annual_leave'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['year'] = year;
    data['annual_leave'] = annualLeave;
    return data;
  }

  String toPlain() {
    return 'UserAnnualLeaveModel{ year: $year, annualLeave: $annualLeave }';
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
