abstract class TvboxRepository {
  Future<List<dynamic>> getAllSites(dynamic isar);
  Future<void> updateSites(String url, dynamic isar);
}

abstract class VideoSourceRepository {
  Future<void> initializeDefaultSource(dynamic isar);
  Future<List<dynamic>> getAllSources(dynamic isar);
  Future<void> addSource(dynamic isar, dynamic source);
  Future<void> removeSource(dynamic isar, String key);
  Future<void> setActiveSource(dynamic isar, String key);
  Future<void> updateSource(dynamic isar, dynamic source);
  Future<dynamic> getActiveSource(dynamic isar);
}
