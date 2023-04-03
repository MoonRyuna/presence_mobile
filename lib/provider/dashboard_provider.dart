import 'package:flutter/material.dart';
import 'package:presence_alpha/payload/data/presensi_data.dart';

class DashboardProvider with ChangeNotifier {
  PresensiData? _presensi;
  PresensiData? get presensi => _presensi;
  set presensi(PresensiData? value) {
    _presensi = value;
    notifyListeners();
  }

  int? _izin;
  int? get izin => _izin;
  set izin(int? value) {
    _izin = value;
    notifyListeners();
  }

  int? _lembur;
  int? get lembur => _lembur;
  set lembur(int? value) {
    _lembur = value;
    notifyListeners();
  }
}
