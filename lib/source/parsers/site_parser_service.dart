import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/entities/video.dart';
import '../../domain/media_source/video_source_config.dart';

final siteParserServiceProvider = Provider<SiteParserService>((ref) {
  return SiteParserService();
});

class SiteParserService {
  final Map<String, SiteParser> _parsers = {
    'meowtv': MeowTvParser(),
  };

  SiteParser getParser(String siteKey) {
    return _parsers[siteKey] ?? DefaultSiteParser();
  }

  Future<List<Video>> parseVideos(String siteKey, dynamic response, VideoSourceConfig site) async {
    final parser = getParser(siteKey);
    return parser.parseVideos(response, site);
  }

  Future<Video> parseVideoDetail(String siteKey, dynamic response, VideoSourceConfig site) async {
    final parser = getParser(siteKey);
    return parser.parseVideoDetail(response, site);
  }
}

abstract class SiteParser {
  Future<List<Video>> parseVideos(dynamic response, VideoSourceConfig site);
  Future<Video> parseVideoDetail(dynamic response, VideoSourceConfig site);
}

class DefaultSiteParser implements SiteParser {
  @override
  Future<List<Video>> parseVideos(dynamic response, VideoSourceConfig site) async {
    if (response is! Map<String, dynamic> || !response.containsKey('list')) {
      throw Exception('Invalid response format: missing list field');
    }

    final list = response['list'];
    if (list is! List) {
      throw Exception('Invalid response format: list is not a List');
    }

    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return Video.fromJson(item);
      }
      return null;
    }).whereType<Video>().toList();
  }

  @override
  Future<Video> parseVideoDetail(dynamic response, VideoSourceConfig site) async {
    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }

    return Video.fromJson(response);
  }
}

class MeowTvParser implements SiteParser {
  @override
  Future<List<Video>> parseVideos(dynamic response, VideoSourceConfig site) async {
    // MeowTV specific parsing logic
    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid MeowTV response format');
    }

    // Check if response has data field
    final data = response.containsKey('data') ? response['data'] : response;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid MeowTV data format');
    }

    // Check for list field
    if (!data.containsKey('list')) {
      throw Exception('Invalid MeowTV response: missing list field');
    }

    final list = data['list'];
    if (list is! List) {
      throw Exception('Invalid MeowTV response: list is not a List');
    }

    return list.map((item) {
      if (item is Map<String, dynamic>) {
        // Map MeowTV fields to Video model
        return Video(
          id: item['id']?.toString() ?? '',
          title: item['title'] ?? '',
          coverUrl: item['pic'] ?? item['cover'] ?? '',
          videoUrl: item['url'] ?? '',
          description: item['desc'] ?? '',
          category: item['type']?.toString() ?? '',
          source: site.key,
          score: item['score']?.toString() ?? '',
          year: item['year']?.toString() ?? '',
          area: item['area']?.toString() ?? '',
          actor: item['actors'] ?? '',
          director: item['director'] ?? '',
        );
      }
      return null;
    }).whereType<Video>().toList();
  }

  @override
  Future<Video> parseVideoDetail(dynamic response, VideoSourceConfig site) async {
    // MeowTV specific video detail parsing logic
    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid MeowTV detail response format');
    }

    final data = response.containsKey('data') ? response['data'] : response;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid MeowTV detail data format');
    }

    return Video(
      id: data['id']?.toString() ?? '',
      title: data['title'] ?? '',
      coverUrl: data['pic'] ?? data['cover'] ?? '',
      videoUrl: data['url'] ?? '',
      description: data['desc'] ?? '',
      category: data['type']?.toString() ?? '',
      source: site.key,
      score: data['score']?.toString() ?? '',
      year: data['year']?.toString() ?? '',
      area: data['area']?.toString() ?? '',
      actor: data['actors'] ?? '',
      director: data['director'] ?? '',
    );
  }
}