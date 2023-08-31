import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  const Storage();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<int?> readIntOrNull(String key) async {
    var str = await _storage.read(key: key);
    if (str != null) {
      return int.parse(str);
    }
    return null;
  }
}
