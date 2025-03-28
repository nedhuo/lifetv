import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_source_config.dart';
import '../../../../features/home/domain/models/video.dart';

class VideoSourceService {
  static const String _proxyUrl = 'https://api.allorigins.win/raw?url=';
  static const String _corsProxyUrl = 'https://cors.eu.org/';

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
      print('获取视频源配置出错: $e');
      rethrow;
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

      return _parseVideoList(response.body, source);
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

      return _parseVideoList(response.body, source);
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

  List<Video> _parseVideoList(String responseBody, VideoSourceConfig source) {
    try {
      print('解析视频列表响应: $responseBody');
      final Map<String, dynamic> data = json.decode(responseBody);
      
      if (!data.containsKey('list')) {
        // 尝试在data字段中查找list
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          final dataMap = data['data'] as Map<String, dynamic>;
          if (dataMap.containsKey('list')) {
            return _parseVideoItems(dataMap['list'], source);
          }
        }
        throw Exception('视频列表格式错误: 缺少 list 字段');
      }

      return _parseVideoItems(data['list'], source);
    } catch (e) {
      print('解析视频列表失败: $e');
      rethrow;
    }
  }

  List<Video> _parseVideoItems(dynamic list, VideoSourceConfig source) {
    if (list is! List) {
      throw Exception('视频列表格式错误: list 不是数组');
    }

    return list.map((item) {
      if (item is! Map<String, dynamic>) {
        print('无效的视频数据格式: $item');
        return null;
      }
      
      // 添加视频源信息
      item['source'] = source.key;
      return Video.fromJson(item);
    }).whereType<Video>().toList();
  }

  Future<List<Map<String, dynamic>>> fetchCategories(VideoSourceConfig source) async {
    try {
      final baseUrl = _getBaseUrl(source);
      if (baseUrl.isEmpty) {
        print('使用API获取分类列表: ${source.api}');
        return _fetchCategoriesFromApi(source);
      }

      print('获取分类列表: $baseUrl');
      var response = await http.get(
        Uri.parse(baseUrl),
        headers: _getHeaders(source),
      );

      if (response.statusCode != 200 || response.body.trim().startsWith('<!DOCTYPE')) {
        print('直接请求失败，尝试使用CORS代理');
        response = await http.get(
          Uri.parse('$_corsProxyUrl$baseUrl'),
          headers: _getHeaders(source),
        );
      }

      if (response.statusCode != 200) {
        throw Exception('获取分类列表失败: HTTP ${response.statusCode}');
      }

      return _parseCategories(response.body);
    } catch (e) {
      print('获取分类列表出错: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCategoriesFromApi(VideoSourceConfig source) async {
    try {
      final apiUrl = '${source.api}?ac=class';
      print('从API获取分类列表: $apiUrl');

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
        throw Exception('从API获取分类列表失败: HTTP ${response.statusCode}');
      }

      return _parseCategories(response.body);
    } catch (e) {
      print('从API获取分类列表出错: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _parseCategories(String responseBody) {
    try {
      print('解析分类列表响应: $responseBody');
      final jsonData = json.decode(responseBody);
      
      if (jsonData is Map<String, dynamic>) {
        if (jsonData.containsKey('class')) {
          final categories = jsonData['class'] as List;
          return _parseCategoryItems(categories);
        } else if (jsonData.containsKey('data') && 
                  jsonData['data'] is Map<String, dynamic> &&
                  jsonData['data'].containsKey('class')) {
          final categories = jsonData['data']['class'] as List;
          return _parseCategoryItems(categories);
        }
      }
      
      print('不支持的分类列表格式');
      return [];
    } catch (e) {
      print('解析分类列表失败: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _parseCategoryItems(List categories) {
    return categories.map((category) {
      return {
        'id': category['type_id']?.toString() ?? '',
        'name': category['type_name']?.toString() ?? '',
      };
    }).toList();
  }
}