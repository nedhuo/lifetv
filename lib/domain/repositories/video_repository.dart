abstract class VideoRepository {
  Future<List<dynamic>> getVideos(String category);
  Future<dynamic> getVideoDetail(String videoId);
}
