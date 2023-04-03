import 'package:flutter/material.dart';
import 'package:presence_alpha/model/office_config_model.dart';

class OfficeConfigProvider with ChangeNotifier {
  OfficeConfigModel? _officeConfig;

  OfficeConfigModel? get officeConfig => _officeConfig;

  set officeConfig(OfficeConfigModel? value) {
    _officeConfig = value;
    notifyListeners();
  }
}
