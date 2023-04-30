import 'dart:convert';

class AbsenceTypeModel {
  BigInt? id;
  String? name;
  bool? cutAnnualLeave;
  BigInt? createdBy;
  BigInt? updatedBy;
  bool? deleted;
  DateTime? deletedAt;
  BigInt? deletedBy;

  AbsenceTypeModel({
    this.id,
    this.name,
    this.cutAnnualLeave,
    this.createdBy,
    this.updatedBy,
    this.deleted,
    this.deletedAt,
    this.deletedBy,
  });

  AbsenceTypeModel.fromJson(Map<String, dynamic> json) {
    id = BigInt.from(json['id']);
    name = json['name'];
    cutAnnualLeave = json['cut_annual_leave'];
    createdBy = BigInt.from(json['created_by']);
    updatedBy = BigInt.from(json['updated_by']);
    deleted = json['deleted'];
    deletedAt =
        json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null;
    deletedBy =
        json['deleted_by'] != null ? BigInt.from(json['deleted_by']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id.toString();
    data['name'] = name;
    data['cut_annual_leave'] = cutAnnualLeave;
    data['created_by'] = createdBy.toString();
    data['updated_by'] = updatedBy.toString();
    data['deleted'] = deleted;
    data['deletedAt'] = deletedAt?.toIso8601String();
    data['deleted_by'] = deletedBy?.toString();
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
