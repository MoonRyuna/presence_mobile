import 'dart:convert';

class DateRangeModel {
  String? startDate;
  String? endDate;

  DateRangeModel({
    this.startDate,
    this.endDate,
  });

  factory DateRangeModel.fromJson(Map<String, dynamic> json) {
    return DateRangeModel(
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
