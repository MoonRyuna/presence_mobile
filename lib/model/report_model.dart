class ReportModel {
  BigInt? id;
  String? title;
  DateTime? startDate;
  DateTime? endDate;
  int? totalEmployee;
  BigInt? generatedBy;
  DateTime? generatedAt;

  ReportModel({
    this.id,
    this.title,
    this.startDate,
    this.endDate,
    this.totalEmployee,
    this.generatedBy,
    this.generatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: BigInt.from(json['id']),
      title: json['title'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalEmployee: json['total_employee'],
      generatedBy: BigInt.from(json['generated_by']),
      generatedAt: DateTime.parse(json['generated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id.toString();
    data['title'] = title;
    data['start_date'] = startDate?.toIso8601String();
    data['end_date'] = endDate?.toIso8601String();
    data['total_employee'] = totalEmployee;
    data['generated_by'] = generatedBy.toString();
    data['generated_at'] = generatedAt?.toIso8601String();
    return data;
  }
}
