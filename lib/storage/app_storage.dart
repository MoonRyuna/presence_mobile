import 'package:path_provider/path_provider.dart';
import 'package:localstorage/localstorage.dart';

class AppStorage {
  static late LocalStorage _localStorage;

  static LocalStorage get localStorage => _localStorage;

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    _localStorage = LocalStorage('thislocal.json', directory.path);
    await _localStorage.ready;
  }
}
