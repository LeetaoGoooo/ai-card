import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _sharedPrefs;

  factory SharedPrefs() => SharedPrefs._internal();

  SharedPrefs._internal();

  init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  _clear(String key) async {
    await _sharedPrefs.remove(key);
  }

  String? get apiKey => _sharedPrefs.getString("apiKey");

  String? get baseUrl => _sharedPrefs.getString("baseUrl") ?? "https://api.anthropic.com/v1";

  set apiKey(String? apiKey) {
    _sharedPrefs.setString("apiKey", apiKey!);
  }

  set baseUrl(String? baseUrl) {
    _sharedPrefs.setString("baseUrl", baseUrl!);
  }

  bool get enableProxy => _sharedPrefs.getBool("enableProxy") ?? false;

  set enableProxy(bool? enableProxy)  {
     _sharedPrefs.setBool("enableProxy", enableProxy!);
  }
}
