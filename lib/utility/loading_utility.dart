import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoadingUtility {
  static void show(String? message) {
    message = message ?? 'Sedang Diproses';

    EasyLoading.instance
      ..radius = 8.0
      ..indicatorType = EasyLoadingIndicatorType.ripple
      ..loadingStyle = EasyLoadingStyle.light
      ..maskType = EasyLoadingMaskType.black
      ..indicatorSize = 50.0;
    EasyLoading.show(status: message);
  }

  static void hide() {
    EasyLoading.dismiss();
  }
}
