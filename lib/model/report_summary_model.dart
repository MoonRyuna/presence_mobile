import 'dart:convert';

import 'package:presence_alpha/model/report_model.dart';
import 'package:presence_alpha/model/user_model.dart';

class ReportSummaryModel {
  int? id;
  String? userId;
  String? reportId;
  int? hadir;
  int? tanpaKeterangan;
  int? cuti;
  int? sakit;
  int? izinLainnya;
  int? telat;
  int? wfh;
  int? wfo;
  int? lembur;
  int? fulltime;
  int? hariKerja;
  UserModel? user;
  ReportModel? report;

  ReportSummaryModel({
    this.id,
    this.userId,
    this.reportId,
    this.hadir,
    this.tanpaKeterangan,
    this.cuti,
    this.sakit,
    this.izinLainnya,
    this.telat,
    this.wfh,
    this.wfo,
    this.lembur,
    this.fulltime,
    this.hariKerja,
    this.user,
    this.report,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      id: json['id'],
      userId: json['user_id'],
      reportId: json['report_id'],
      hadir: json['hadir'],
      tanpaKeterangan: json['tanpa_keterangan'],
      cuti: json['cuti'],
      sakit: json['sakit'],
      izinLainnya: json['izin_lainnya'],
      telat: json['telat'],
      wfh: json['wfh'],
      wfo: json['wfo'],
      lembur: json['lembur'],
      fulltime: json['fulltime'],
      hariKerja: json['hari_kerja'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      report:
          json['report'] != null ? ReportModel.fromJson(json['report']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['report_id'] = reportId;
    data['hadir'] = hadir;
    data['tanpa_keterangan'] = tanpaKeterangan;
    data['cuti'] = cuti;
    data['sakit'] = sakit;
    data['izin_lainnya'] = izinLainnya;
    data['telat'] = telat;
    data['wfh'] = wfh;
    data['wfo'] = wfo;
    data['lembur'] = lembur;
    data['fulltime'] = fulltime;
    data['hari_kerja'] = hariKerja;
    data['user'] = user != null ? user!.toJson() : null;
    data['report'] = report != null ? report!.toJson() : null;
    return data;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
