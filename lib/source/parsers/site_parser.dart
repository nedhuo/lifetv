import '../../domain/media_source/video_source.dart';
import '../../domain/entities/video.dart';

/// 站点解析器接口
abstract class SiteParser {
  /// 解析站点配置
  Future<Map<String, dynamic>> parseSiteConfig(String url);
  
  /// 解析视频分类
  Future<List<VideoCategory>> parseCategories(dynamic data);
  
  /// 解析视频列表
  Future<List<Video>> parseVideoList(dynamic data, String sourceKey);
  
  /// 解析视频详情
  Future<VideoDetail> parseVideoDetail(dynamic data, String sourceKey);
  
  /// 解析播放链接
  Future<List<VideoPlayUrl>> parsePlayUrls(dynamic data);
  
  /// 搜索视频
  Future<List<Video>> searchVideos(String keyword, String sourceKey);
}

/// 默认站点解析器实现
class DefaultSiteParser implements SiteParser {
  @override
  Future<Map<String, dynamic>> parseSiteConfig(String url) async {
    // 默认实现，直接返回空配置
    return {};
  }

  @override
  Future<List<VideoCategory>> parseCategories(dynamic data) async {
    if (data is! List) {
      return [];
    }
    
    return data.map((item) {
      if (item is Map<String, dynamic>) {
        return VideoCategory(
          id: item['id']?.toString() ?? '',
          name: item['name']?.toString() ?? '',
          type: item['type']?.toString() ?? 'category',
          children: [],
        );
      }
      return null;
    }).whereType<VideoCategory>().toList();
  }

  @override
  Future<List<Video>> parseVideoList(dynamic data, String sourceKey) async {
    if (data is! List) {
      return [];
    }
    
    return data.map((item) {
      if (item is Map<String, dynamic>) {
        item['source'] = sourceKey;
        return Video.fromJson(item);
      }
      return null;
    }).whereType<Video>().toList();
  }

  @override
  Future<VideoDetail> parseVideoDetail(dynamic data, String sourceKey) async {
    if (data is! Map<String, dynamic>) {
      throw Exception('无效的视频详情数据');
    }
    
    return VideoDetail(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      coverUrl: data['coverUrl']?.toString() ?? '',
      description: data['description']?.toString(),
      playUrls: [],
      director: data['director']?.toString(),
      actors: data['actors']?.toString(),
      area: data['area']?.toString(),
      year: data['year']?.toString(),
      status: data['status']?.toString(),
      categories: [],
    );
  }

  @override
  Future<List<VideoPlayUrl>> parsePlayUrls(dynamic data) async {
    if (data is! List) {
      return [];
    }
    
    return data.map((item) {
      if (item is Map<String, dynamic>) {
        return VideoPlayUrl(
          name: item['name']?.toString() ?? '',
          url: item['url']?.toString() ?? '',
          quality: item['quality']?.toString(),
          isM3U8: item['isM3U8'] ?? false,
        );
      }
      return null;
    }).whereType<VideoPlayUrl>().toList();
  }

  @override
  Future<List<Video>> searchVideos(String keyword, String sourceKey) async {
    // 默认实现，返回空列表
    return [];
  }
}

/// MeowTV站点解析器实现
class MeowTvParser implements SiteParser {
  @override
  Future<Map<String, dynamic>> parseSiteConfig(String url) async {
    // MeowTV站点配置解析
    return {
      'name': 'MeowTV',
      'key': 'meowtv',
      'api': url,
      'enabled': true,
    };
  }

  @override
  Future<List<VideoCategory>> parseCategories(dynamic data) async {
    // MeowTV分类解析
    if (data is! Map<String, dynamic> || !data.containsKey('class')) {
      return [];
    }
    
    final List<dynamic> categories = data['class'];
    return categories.map((item) {
      if (item is Map<String, dynamic>) {
        return VideoCategory(
          id: item['id']?.toString() ?? '',
          name: item['name']?.toString() ?? '',
          type: item['type']?.toString() ?? 'category',
          children: [],
        );
      }
      return null;
    }).whereType<VideoCategory>().toList();
  }

  @override
  Future<List<Video>> parseVideoList(dynamic data, String sourceKey) async {
    // MeowTV视频列表解析
    if (data is! Map<String, dynamic> || !data.containsKey('list')) {
      return [];
    }
    
    final List<dynamic> videos = data['list'];
    return videos.map((item) {
      if (item is Map<String, dynamic>) {
        item['source'] = sourceKey;
        return Video(
          id: item['id']?.toString() ?? '',
          title: item['name']?.toString() ?? '',
          coverUrl: item['pic']?.toString() ?? '',
          videoUrl: item['url']?.toString() ?? '',
          description: item['desc']?.toString() ?? '',
          source: sourceKey,
        );
      }
      return null;
    }).whereType<Video>().toList();
  }

  @override
  Future<VideoDetail> parseVideoDetail(dynamic data, String sourceKey) async {
    // MeowTV视频详情解析
    if (data is! Map<String, dynamic>) {
      throw Exception('无效的视频详情数据');
    }
    
    final List<VideoPlayUrl> playUrls = [];
    if (data.containsKey('playUrl')) {
      final playUrlData = data['playUrl'];
      if (playUrlData is Map<String, dynamic>) {
        playUrlData.forEach((name, url) {
          if (url is String) {
            playUrls.add(VideoPlayUrl(
              name: name,
              url: url,
              isM3U8: url.contains('.m3u8'),
            ));
          }
        });
      }
    }
    
    return VideoDetail(
      id: data['id']?.toString() ?? '',
      title: data['name']?.toString() ?? '',
      coverUrl: data['pic']?.toString() ?? '',
      description: data['desc']?.toString(),
      playUrls: playUrls,
      director: data['director']?.toString(),
      actors: data['actor']?.toString(),
      area: data['area']?.toString(),
      year: data['year']?.toString(),
      status: data['status']?.toString(),
      categories: [],
    );
  }

  @override
  Future<List<VideoPlayUrl>> parsePlayUrls(dynamic data) async {
    // MeowTV播放链接解析
    final List<VideoPlayUrl> playUrls = [];
    
    if (data is Map<String, dynamic>) {
      data.forEach((name, url) {
        if (url is String) {
          playUrls.add(VideoPlayUrl(
            name: name,
            url: url,
            isM3U8: url.contains('.m3u8'),
          ));
        }
      });
    }
    
    return playUrls;
  }

  @override
  Future<List<Video>> searchVideos(String keyword, String sourceKey) async {
    // MeowTV搜索实现
    return [];
  }
}

/// 站点解析器工厂
class SiteParserFactory {
  /// 根据站点类型获取解析器
  static SiteParser getParser(String siteType) {
    switch (siteType.toLowerCase()) {
      case 'meowtv':
        return MeowTvParser();
      default:
        return DefaultSiteParser();
    }
  }
  
  /// 根据URL获取解析器
  static SiteParser getParserByUrl(String url) {
    if (url.contains('meowtv')) {
      return MeowTvParser();
    }
    return DefaultSiteParser();
  }
}