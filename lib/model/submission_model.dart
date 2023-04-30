import 'dart:convert';

class SubmissionModel {
  BigInt? id;
  String? submissionType;
  DateTime? submissionAt;
  String? submissionStatus;
  String? submissionRefTable;
  BigInt? submissionRefId;
  BigInt? authorizationBy;
  DateTime? authorizationAt;

  SubmissionModel({
    this.id,
    this.submissionType,
    this.submissionAt,
    this.submissionStatus,
    this.submissionRefTable,
    this.submissionRefId,
    this.authorizationBy,
    this.authorizationAt,
  });

  SubmissionModel.fromJson(Map<String, dynamic> json) {
    id = BigInt.from(json['id']);
    submissionType = json['submission_type'];
    submissionAt = DateTime.parse(json['submission_at']);
    submissionStatus = json['submission_status'];
    submissionRefTable = json['submission_ref_table'];
    submissionRefId = BigInt.from(json['submission_ref_id']);
    authorizationBy = BigInt.from(json['authorization_by']);
    authorizationAt = DateTime.parse(json['authorization_at']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id.toString();
    data['submission_type'] = submissionType;
    data['submission_at'] = submissionAt?.toIso8601String();
    data['submission_status'] = submissionStatus;
    data['submission_ref_table'] = submissionRefTable;
    data['submission_ref_id'] = submissionRefId.toString();
    data['authorization_by'] = authorizationBy.toString();
    data['authorization_at'] = authorizationAt?.toIso8601String();
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
