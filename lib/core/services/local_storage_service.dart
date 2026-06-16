class LocalStorageService {
  // A simple in-memory database mock.
  // In a real application, this would use shared_preferences, hive, or sqflite.
  static final Map<String, String> _inMemoryDb = {};

  Future<void> init() async {
    // Initialization logic if needed
  }

  Future<bool> setString(String key, String value) async {
    _inMemoryDb[key] = value;
    return true;
  }

  Future<String?> getString(String key) async {
    return _inMemoryDb[key];
  }

  Future<bool> setBool(String key, bool value) async {
    _inMemoryDb[key] = value.toString();
    return true;
  }

  Future<bool?> getBool(String key) async {
    final val = _inMemoryDb[key];
    if (val == null) return null;
    return val.toLowerCase() == 'true';
  }

  Future<bool> remove(String key) async {
    return _inMemoryDb.remove(key) != null;
  }

  Future<bool> clear() async {
    _inMemoryDb.clear();
    return true;
  }
}
