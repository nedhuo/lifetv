import 'dart:collection';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import '../../domain/media_source/video_source_config.dart';
import '../../domain/entities/video.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/dtos/video_source_entity.dart';
import 'package:dio/dio.dart';
import '../../source/parsers/site_parser.dart';

final videoSourceServiceProvider = Provider<VideoSourceService>((ref) {
  return VideoSourceService();
});

class VideoSourceService {
  static const String _proxyUrl = 'https://api.allorigins.win/raw?url=';
  static const String _corsProxyUrl = 'https://cors.eu.org/';
  final String defaultSourceUrl = 'https://raw.githubusercontent.com/nedhuo/tvbox/main/tvbox.json';
  final _dio = Dio();

  Future<VideoSourceResponse> fetchSourceConfig(String url) async {
    try {
      // 尝试直接请求
      print('尝试直接请求视频源配置: $url');
      var response = await http.get(Uri.parse(url));
      
      if (response.statusCode != 200 || response.body.trim().startsWith('<!DOCTYPE')) {
        print('直接请求失败，尝试使用CORS代理');
        response = await http.get(Uri.parse('$_corsProxyUrl$url'));
      }

      if (response.statusCode != 200 || response.body.trim().startsWith('<!DOCTYPE')) {
        print('CORS代理请求失败，尝试使用AllOrigins代理');
        response = await http.get(Uri.parse('$_proxyUrl${Uri.encodeComponent(url)}'));
      }

      if (response.statusCode != 200) {
        throw Exception('获取视频源配置失败: HTTP ${response.statusCode}');
      }

      if (response.body.trim().startsWith('<!DOCTYPE')) {
        throw Exception('获取视频源配置失败: 返回了HTML页面而不是JSON数据');
      }

      print('成功获取视频源配置，解析响应数据...');
      final String responseBody = response.body.trim();
      print('响应数据: $responseBody');
      
      final Map<String, dynamic> data = json.decode(responseBody);
      
      if (!data.containsKey('sites')) {
        throw Exception('视频源配置格式错误: 缺少 sites 字段');
      }

      return VideoSourceResponse.fromJson(data);
    } catch (e) {
      print('获取视频源配置失败: $e');
      throw Exception('获取视频源配置失败: $e');
    }
  }

  Future<List<Video>> fetchVideos(VideoSourceConfig source, {String? categoryId}) async {
    try {
      final baseUrl = _getBaseUrl(source);
      if (baseUrl.isEmpty) {
        print('使用API作为基础URL: ${source.api}');
        return _fetchVideosFromApi(source, categoryId: categoryId);
      }

      final apiUrl = _buildApiUrl(baseUrl, source, categoryId);
      print('获取视频列表: $apiUrl');
      
      var response = await http.get(
        Uri.parse(apiUrl),
        headers: _getHeaders(source),
      );

      if (response.statusCode != 200 || response.body.trim().startsWith('<!DOCTYPE')) {
        print('直接请求失败，尝试使用CORS代理');
        response = await http.get(
          Uri.parse('$_corsProxyUrl$apiUrl'),
          headers: _getHeaders(source),
        );
      }

      if (response.statusCode != 200) {
        throw Exception('获取视频列表失败: HTTP ${response.statusCode}');
      }

      return await _parseVideoList(response.body, source);
    } catch (e) {
      print('获取视频列表出错: $e');
      rethrow;
    }
  }

  Future<List<Video>> _fetchVideosFromApi(VideoSourceConfig source, {String? categoryId}) async {
    try {
      final params = {
        'ac': 'videolist',
        'pg': '1',
        if (categoryId != null) 'tid': categoryId,
      };

      final queryString = params.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final apiUrl = '${source.api}${queryString.isEmpty ? '' : '?$queryString'}';
      print('从API获取视频列表: $apiUrl');

      var response = await http.get(
        Uri.parse(apiUrl),
        headers: _getHeaders(source),
      );

      if (response.statusCode != 200 || response.body.trim().startsWith('<!DOCTYPE')) {
        print('直接请求失败，尝试使用CORS代理');
        response = await http.get(
          Uri.parse('$_corsProxyUrl$apiUrl'),
          headers: _getHeaders(source),
        );
      }

      if (response.statusCode != 200) {
        throw Exception('从API获取视频列表失败: HTTP ${response.statusCode}');
      }

      return await _parseVideoList(response.body, source);
    } catch (e) {
      print('从API获取视频列表出错: $e');
      rethrow;
    }
  }

  String _getBaseUrl(VideoSourceConfig source) {
    if (source.ext == null || source.ext!.isEmpty) {
      return '';
    }

    try {
      final decoded = utf8.decode(base64.decode(source.ext!));
      print('解码后的扩展参数: $decoded');
      return decoded;
    } catch (e) {
      print('解析扩展参数失败: $e');
      return '';
    }
  }

  String _buildApiUrl(String baseUrl, VideoSourceConfig source, String? categoryId) {
    final params = {
      'ac': 'list',
      'pg': '1',
      if (categoryId != null) 'tid': categoryId,
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return '$baseUrl${queryString.isEmpty ? '' : '?$queryString'}';
  }

  Map<String, String> _getHeaders(VideoSourceConfig source) {
    return {
      'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'Origin': 'null',
      'Referer': 'null',
    };
  }

  Future<List<Video>> _parseVideoList(String responseBody, VideoSourceConfig source) async {
    try {
      print('解析视频列表响应: $responseBody');
      final Map<String, dynamic> data = json.decode(responseBody);
      
      // 使用站点解析器解析视频列表
      final parser = SiteParserFactory.getParserByUrl(source.url);
      return await parser.parseVideoList(data, source.key);
    } catch (e) {
      print('解析视频列表失败: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories(VideoSourceEntity source) async {
    try {
      // 尝试直接请求
      print('尝试直接请求分类: ${source.url}');
      var response = await _dio.get(source.url);
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('class')) {
          return List<Map<String, dynamic>>.from(data['class']);
        }
      }

      // 尝试使用 CORS 代理
      print('直接请求失败，尝试使用CORS代理');
      response = await _dio.get('$_corsProxyUrl${source.url}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('class')) {
          return List<Map<String, dynamic>>.from(data['class']);
        }
      }

      // 尝试使用 AllOrigins 代理
      print('CORS代理请求失败，尝试使用AllOrigins代理');
      response = await _dio.get('$_proxyUrl${Uri.encodeComponent(source.url)}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('class')) {
          return List<Map<String, dynamic>>.from(data['class']);
        }
      }

      print('所有代理请求都失败');
      return [];
    } catch (e) {
      print('获取分类失败: $e');
      return [];
    }
  }

  Future<List<VideoSourceEntity>> getAllSources(List<VideoSourceEntity> sources) async {
    return sources;
  }

  Future<VideoSourceEntity?> getActiveSource(List<VideoSourceEntity> sources) async {
    return sources.firstWhereOrNull((source) => source.isActive);
  }

  Future<VideoSourceEntity?> getDefaultSource(List<VideoSourceEntity> sources) async {
    return sources.firstWhereOrNull((source) => source.isDefault);
  }

  Future<bool> validateSource(String url) async {
    try {
      print('验证视频源: $url');
      final response = await fetchSourceConfig(url);
      return response.sites.isNotEmpty;
    } catch (e) {
      print('视频源验证失败: $e');
      return false;
    }
  }

  Future<List<VideoSourceEntity>> addSource(List<VideoSourceEntity> sources, VideoSourceEntity source) async {
    final updatedSources = [...sources];
    updatedSources.add(source);
    return updatedSources;
  }

  Future<List<VideoSourceEntity>> removeSource(List<VideoSourceEntity> sources, String key) async {
    final updatedSources = [...sources];
    updatedSources.removeWhere((s) => s.key == key);
    return updatedSources;
  }

  Future<List<VideoSourceEntity>> setActiveSource(List<VideoSourceEntity> sources, String key) async {
    final updatedSources = [...sources];
    // 先将所有源设置为非活跃
    for (var i = 0; i < updatedSources.length; i++) {
      updatedSources[i] = VideoSourceEntity(
        key: updatedSources[i].key,
        name: updatedSources[i].name,
        url: updatedSources[i].url,
        api: updatedSources[i].api,
        type: updatedSources[i].type,
        group: updatedSources[i].group,
        logo: updatedSources[i].logo,
        ua: updatedSources[i].ua,
        referer: updatedSources[i].referer,
        origin: updatedSources[i].origin,
        cookie: updatedSources[i].cookie,
        proxy: updatedSources[i].proxy,
        header: updatedSources[i].header,
        click: updatedSources[i].click,
        desc: updatedSources[i].desc,
        ext: updatedSources[i].ext,
        jar: updatedSources[i].jar,
        categories: updatedSources[i].categories,
        searchable: updatedSources[i].searchable,
        quickSearch: updatedSources[i].quickSearch,
        filterable: updatedSources[i].filterable,
        playerType: updatedSources[i].playerType,
        searchUrl: updatedSources[i].searchUrl,
        playUrl: updatedSources[i].playUrl,
        isDefault: updatedSources[i].isDefault,
        isActive: false,
      )..id = updatedSources[i].id
       ..createdAt = updatedSources[i].createdAt
       ..updatedAt = updatedSources[i].updatedAt;
    }

    // 将指定源设置为活跃
    final sourceIndex = updatedSources.indexWhere((s) => s.key == key);
    if (sourceIndex != -1) {
      final source = updatedSources[sourceIndex];
      updatedSources[sourceIndex] = VideoSourceEntity(
        key: source.key,
        name: source.name,
        url: source.url,
        api: source.api,
        type: source.type,
        group: source.group,
        logo: source.logo,
        ua: source.ua,
        referer: source.referer,
        origin: source.origin,
        cookie: source.cookie,
        proxy: source.proxy,
        header: source.header,
        click: source.click,
        desc: source.desc,
        ext: source.ext,
        jar: source.jar,
        categories: source.categories,
        searchable: source.searchable,
        quickSearch: source.quickSearch,
        filterable: source.filterable,
        playerType: source.playerType,
        searchUrl: source.searchUrl,
        playUrl: source.playUrl,
        isDefault: source.isDefault,
        isActive: true,
      )..id = source.id
       ..createdAt = source.createdAt
       ..updatedAt = DateTime.now();
    }

    return updatedSources;
  }

  Future<List<VideoSourceEntity>> initializeDefaultSource(List<VideoSourceEntity> sources) async {
    final defaultSource = sources.firstWhereOrNull((s) => s.isDefault);
    if (defaultSource == null) {
      try {
        final config = await fetchSourceConfig(defaultSourceUrl);
        if (config.sites.isNotEmpty) {
          final source = VideoSourceEntity.fromConfig(config.sites.first);
          final updatedSource = VideoSourceEntity(
            key: source.key,
            name: source.name,
            url: source.url,
            api: source.api,
            type: source.type,
            group: source.group,
            logo: source.logo,
            ua: source.ua,
            referer: source.referer,
            origin: source.origin,
            cookie: source.cookie,
            proxy: source.proxy,
            header: source.header,
            click: source.click,
            desc: source.desc,
            ext: source.ext,
            jar: source.jar,
            categories: source.categories,
            searchable: source.searchable,
            quickSearch: source.quickSearch,
            filterable: source.filterable,
            playerType: source.playerType,
            searchUrl: source.searchUrl,
            playUrl: source.playUrl,
            isDefault: true,
            isActive: true,
          );
          return [...sources, updatedSource];
        }
      } catch (e) {
        print('初始化默认视频源失败: $e');
      }
    }
    return sources;
  }

  Future<List<VideoSourceEntity>> updateSource(List<VideoSourceEntity> sources, VideoSourceEntity updatedSource) async {
    final updatedSources = [...sources];
    final index = updatedSources.indexWhere((s) => s.key == updatedSource.key);
    if (index != -1) {
      final source = updatedSources[index];
      updatedSources[index] = VideoSourceEntity(
        key: updatedSource.key,
        name: updatedSource.name,
        url: updatedSource.url,
        api: updatedSource.api,
        type: updatedSource.type,
        group: updatedSource.group,
        logo: updatedSource.logo,
        ua: updatedSource.ua,
        referer: updatedSource.referer,
        origin: updatedSource.origin,
        cookie: updatedSource.cookie,
        proxy: updatedSource.proxy,
        header: updatedSource.header,
        click: updatedSource.click,
        desc: updatedSource.desc,
        ext: updatedSource.ext,
        jar: updatedSource.jar,
        categories: updatedSource.categories,
        searchable: updatedSource.searchable,
        quickSearch: updatedSource.quickSearch,
        filterable: updatedSource.filterable,
        playerType: updatedSource.playerType,
        searchUrl: updatedSource.searchUrl,
        playUrl: updatedSource.playUrl,
        isDefault: updatedSource.isDefault,
        isActive: updatedSource.isActive,
      )..id = source.id
       ..createdAt = source.createdAt
       ..updatedAt = DateTime.now();
    }
    return updatedSources;
  }
}