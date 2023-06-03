import 'dart:convert';

class SubmissionAdminModel {
  int? id;
  String? submissionType;
  String? submissionAt;
  String? submissionStatus;
  String? submissionRefTable;
  String? submissionRefId;
  String? authorizationBy;
  String? authorizationAt;
  String? description;
  String? cutAnnualLeave;
  String? absenceType;
  String? absenceAt;
  String? overtimeAt;
  String? name;

  SubmissionAdminModel({
    this.id,
    this.submissionType,
    this.submissionAt,
    this.submissionStatus,
    this.submissionRefTable,
    this.submissionRefId,
    this.authorizationBy,
    this.authorizationAt,
    this.description,
    this.cutAnnualLeave,
    this.absenceType,
    this.absenceAt,
    this.name,
    this.overtimeAt,
  });

  factory SubmissionAdminModel.fromJson(Map<String, dynamic> json) {
    return SubmissionAdminModel(
      id: json['id'],
      submissionType: json['submission_type'],
      submissionAt: json['submission_at'],
      submissionStatus: json['submission_status'],
      submissionRefTable: json['submission_ref_table'],
      submissionRefId: json['submission_ref_id'],
      authorizationBy: json['authorization_by'],
      authorizationAt: json['authorization_at'],
      description: json['desc'],
      cutAnnualLeave: json['cut_annual_leave'],
      absenceType: json['absence_type'],
      absenceAt: json['absence_at'],
      overtimeAt: json['overtime_at'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['submission_type'] = submissionType;
    data['submission_at'] = submissionAt;
    data['submission_status'] = submissionStatus;
    data['submission_ref_table'] = submissionRefTable;
    data['submission_ref_id'] = submissionRefId;
    data['authorization_by'] = authorizationBy;
    data['authorization_at'] = authorizationAt;
    data['desc'] = description;
    data['cut_annual_leave'] = cutAnnualLeave;
    data['absence_type'] = absenceType;
    data['absence_at'] = absenceAt;
    data['overtime_at'] = overtimeAt;
    data['name'] = name;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
