import 'dart:convert';

class OfficeConfigModel {
  BigInt? id;
  String? name;
  String? theme;
  String? logo;
  double? latitude;
  double? longitude;
  int? radius;
  int? cutOffDate;
  int? amountOfAnnualLeave;
  String? workSchedule;
  String? updatedBy;
  DateTime? updatedAt;

  OfficeConfigModel(
      {this.id,
      this.name,
      this.theme,
      this.logo,
      this.latitude,
      this.longitude,
      this.radius,
      this.cutOffDate,
      this.amountOfAnnualLeave,
      this.workSchedule,
      this.updatedBy,
      this.updatedAt});

  OfficeConfigModel.fromJson(Map<String, dynamic> json) {
    id = BigInt.from(json['id']);
    name = json['name'];
    theme = json['theme'];
    logo = json['logo'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    radius = json['radius'];
    cutOffDate = json['cut_off_date'];
    amountOfAnnualLeave = json['amount_of_annual_leave'];
    workSchedule = json['work_schedule'];
    updatedBy = json['updated_by'];
    updatedAt = DateTime.parse(json['updatedAt']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id.toString();
    data['name'] = name;
    data['theme'] = theme;
    data['logo'] = logo;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['radius'] = radius;
    data['cut_off_date'] = cutOffDate;
    data['amount_of_annual_leave'] = amountOfAnnualLeave;
    data['work_schedule'] = workSchedule;
    data['updated_by'] = updatedBy;
    data['updatedAt'] = updatedAt?.toIso8601String();
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
