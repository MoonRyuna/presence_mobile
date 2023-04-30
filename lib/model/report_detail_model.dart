class ReportDetailModel {
  BigInt? id;
  BigInt? userId;
  BigInt? reportId;
  DateTime? date;
  String? description;

  ReportDetailModel({
    this.id,
    this.userId,
    this.reportId,
    this.date,
    this.description,
  });

  factory ReportDetailModel.fromJson(Map<String, dynamic> json) {
    return ReportDetailModel(
      id: BigInt.from(json['id']),
      userId: BigInt.from(json['user_id']),
      reportId: BigInt.from(json['report_id']),
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id.toString();
    data['user_id'] = userId.toString();
    data['report_id'] = reportId.toString();
    data['date'] = date?.toIso8601String();
    data['description'] = description;
    return data;
  }
}
