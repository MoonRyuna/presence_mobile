import 'package:flutter/services.dart';

class PlatformRepository {
  static const platform =
      MethodChannel('com.example.presence_alpha/mock_location');

  Future<bool> isMockLocationEnabled() async {
    bool res = false;
    try {
      final String result =
          await platform.invokeMethod("isMockLocationEnabled");
      print('RESULT -> $result');
      res = result.toLowerCase() == "true" ? true : false;
    } on PlatformException catch (e) {
      print(e);
    }
    return res;
  }
}
