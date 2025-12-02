import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/tvbox_config.dart';
import '../../data/models/tvbox_site_entity.dart';
import './site_parser_service.dart';

final tvboxServiceProvider = Provider((ref) => TvboxService());

class TvboxService {
  final _dio = Dio();
  final SiteParserService _parserService = SiteParserService();
  
  Future<TvboxConfig> fetchConfig(String url) async {
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final json = response.data;
        return TvboxConfig.fromJson(json);
      } else {
        throw Exception('获取TVBox配置失败');
      }
    } catch (e) {
      throw Exception('获取TVBox配置出错: $e');
    }
  }

  Future<void> saveToDatabase(TvboxConfig config, Isar isar) async {
    try {
      await isar.writeTxn(() async {
        // 保存站点信息
        for (final site in config.sites) {
          final entity = TvboxSiteEntity.fromTvboxSite(site);
          await isar.tvboxSiteEntitys.put(entity);
        }
      });
    } catch (e) {
      throw Exception('保存到数据库出错: $e');
    }
  }

  Future<List<TvboxSiteEntity>> getAllSites(Isar isar) async {
    return await isar.tvboxSiteEntitys.where().findAll();
  }

  Future<void> updateSites(String configUrl, Isar isar) async {
    try {
      final config = await fetchConfig(configUrl);
      await saveToDatabase(config, isar);
    } catch (e) {
      throw Exception('更新站点出错: $e');
    }
  }
  
  // 添加视频获取和解析方法
  Future<dynamic> fetchSiteData(String apiUrl) async {
    try {
      final response = await _dio.get(apiUrl);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('获取站点数据失败: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('获取站点数据出错: $e');
    }
  }
} 