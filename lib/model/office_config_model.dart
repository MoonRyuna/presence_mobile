import 'dart:convert';

class OfficeConfigModel {
  int? id;
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
  String? updatedAt;

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
    id = json['id'];
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
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
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
    data['updatedAt'] = updatedAt;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
