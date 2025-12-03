abstract class TvboxRepository {
  Future<List<dynamic>> getAllSites();
  Future<void> updateSites(String url);
}

abstract class VideoSourceRepository {
  Future<List<dynamic>> initializeDefaultSource(List<dynamic> sources);
  Future<List<dynamic>> getAllSources(List<dynamic> sources);
  Future<List<dynamic>> addSource(List<dynamic> sources, dynamic source);
  Future<List<dynamic>> removeSource(List<dynamic> sources, String key);
  Future<List<dynamic>> setActiveSource(List<dynamic> sources, String key);
  Future<List<dynamic>> updateSource(List<dynamic> sources, dynamic source);
  Future<dynamic> getActiveSource(List<dynamic> sources);
}
