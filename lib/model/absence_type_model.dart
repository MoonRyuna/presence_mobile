import 'dart:convert';

import 'package:presence_alpha/model/user_model.dart';

class AbsenceTypeModel {
  int? id;
  String? name;
  bool? cutAnnualLeave;
  String? createdBy;
  String? updatedBy;
  bool? deleted;
  String? deletedAt;
  String? deletedBy;
  final UserModel? creator;
  final UserModel? updater;
  final UserModel? deleter;

  AbsenceTypeModel(
      {this.id,
      this.name,
      this.cutAnnualLeave,
      this.createdBy,
      this.updatedBy,
      this.deleted,
      this.deletedAt,
      this.deletedBy,
      this.creator,
      this.updater,
      this.deleter});

  factory AbsenceTypeModel.fromJson(Map<String, dynamic> json) {
    return AbsenceTypeModel(
      id: json['id'],
      name: json['name'],
      cutAnnualLeave: json['cut_annual_leave'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      deleted: json['deleted'],
      deletedAt: json['deletedAt'],
      deletedBy: json['deleted_by'],
      creator:
          json['creator'] != null ? UserModel.fromJson(json['creator']) : null,
      updater:
          json['updater'] != null ? UserModel.fromJson(json['updater']) : null,
      deleter:
          json['deleter'] != null ? UserModel.fromJson(json['deleter']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['cut_annual_leave'] = cutAnnualLeave;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    data['deleted'] = deleted;
    data['deletedAt'] = deletedAt;
    data['deleted_by'] = deletedBy;
    data['creator'] = creator != null ? creator!.toJson() : null;
    data['updater'] = updater != null ? updater!.toJson() : null;
    data['deleter'] = deleter != null ? deleter!.toJson() : null;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
