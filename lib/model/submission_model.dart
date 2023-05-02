import 'dart:convert';

import 'package:presence_alpha/model/user_model.dart';

class SubmissionModel {
  int? id;
  String? submissionType;
  String? submissionAt;
  String? submissionStatus;
  String? submissionRefTable;
  String? submissionRefId;
  String? authorizationBy;
  String? authorizationAt;
  UserModel? authorizer;

  SubmissionModel({
    this.id,
    this.submissionType,
    this.submissionAt,
    this.submissionStatus,
    this.submissionRefTable,
    this.submissionRefId,
    this.authorizationBy,
    this.authorizationAt,
    this.authorizer,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'],
      submissionType: json['submission_type'],
      submissionAt: json['submission_at'],
      submissionStatus: json['submission_status'],
      submissionRefTable: json['submission_ref_table'],
      submissionRefId: json['submission_ref_id'],
      authorizationBy: json['authorization_by'],
      authorizationAt: json['authorization_at'],
      authorizer: json['authorizer'] != null
          ? UserModel.fromJson(json['authorizer'])
          : null,
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
    data['authorizer'] = authorizer != null ? authorizer!.toJson() : null;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
