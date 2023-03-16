import 'package:flutter/material.dart';

class DateProvider with ChangeNotifier {
  DateTime _date = DateTime.now();

  DateTime get date => _date;

  void setDate(DateTime date) {
    _date = date;
    notifyListeners();
  }
}
