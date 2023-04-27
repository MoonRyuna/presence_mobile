import 'package:flutter/material.dart';
import 'package:presence_alpha/payload/data/today_check_data.dart';

class PropertiesProvider with ChangeNotifier {
  TodayCheckData? _todayCheckData;

  TodayCheckData? get todayCheckData => _todayCheckData;

  set todayCheckData(TodayCheckData? value) {
    _todayCheckData = value;
    notifyListeners();
  }
}
