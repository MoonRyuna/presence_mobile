import 'package:flutter/material.dart';
import 'package:presence_alpha/model/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  set user(UserModel? value) {
    _user = value;
    notifyListeners();
  }
}
