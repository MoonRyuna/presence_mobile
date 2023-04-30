class ReportSummaryModel {
  BigInt? id;
  BigInt? userId;
  BigInt? reportId;
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
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      id: BigInt.from(json['id']),
      userId: BigInt.from(json['user_id']),
      reportId: BigInt.from(json['report_id']),
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
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id.toString();
    data['user_id'] = userId.toString();
    data['report_id'] = reportId.toString();
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
    return data;
  }
}
