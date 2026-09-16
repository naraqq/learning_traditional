import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ProgressStore {
  Future<String?> read();
  Future<void> write(String value);
}

class PreferencesProgressStore implements ProgressStore {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  static const _key = 'uigarjin.progress.v1';

  @override
  Future<String?> read() => _preferences.getString(_key);

  @override
  Future<void> write(String value) => _preferences.setString(_key, value);
}

class MemoryProgressStore implements ProgressStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;
}
