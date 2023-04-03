import 'dart:convert';

import 'package:presence_alpha/model/office_config_model.dart';
import 'package:presence_alpha/model/user_model.dart';
import 'package:presence_alpha/payload/data/presensi_data.dart';

class Dashboard1Data {
  UserModel? user;
  PresensiData? presensi;
  int? izin;
  int? lembur;
  OfficeConfigModel? officeConfig;

  Dashboard1Data({
    this.user,
    this.presensi,
    this.izin,
    this.lembur,
    this.officeConfig,
  });

  factory Dashboard1Data.fromJson(Map<String, dynamic> json) {
    return Dashboard1Data(
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      presensi: json['presensi'] != null
          ? PresensiData.fromJson(json['presensi'])
          : null,
      izin: json['izin'],
      lembur: json['lembur'],
      officeConfig: json['office_config'] != null
          ? OfficeConfigModel.fromJson(json['office_config'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user != null ? user!.toJson() : null;
    data['presensi'] = presensi != null ? presensi!.toJson() : null;
    data['izin'] = izin;
    data['lembur'] = lembur;
    data['office_config'] =
        officeConfig != null ? officeConfig!.toJson() : null;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
