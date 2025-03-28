import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/video_source_config.dart';
import '../../domain/services/video_source_service.dart';

final videoSourceServiceProvider = Provider((ref) => VideoSourceService());

final selectedSourceProvider = StateProvider<VideoSourceConfig?>((ref) => null);

final videoSourceConfigProvider =
    StateNotifierProvider<VideoSourceConfigNotifier, AsyncValue<VideoSourceResponse?>>(
  (ref) => VideoSourceConfigNotifier(ref.watch(videoSourceServiceProvider)),
);

class VideoSourceConfigNotifier extends StateNotifier<AsyncValue<VideoSourceResponse?>> {
  final VideoSourceService _sourceService;
  static const String _sourceUrlKey = 'video_source_url';
  static const String _selectedSourceKey = 'selected_source_key';
  static const String _defaultSourceUrl = 'http://www.meowtv.top/';

  VideoSourceConfigNotifier(this._sourceService) : super(const AsyncValue.loading()) {
    _loadSourceConfig();
  }

  Future<void> _loadSourceConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? sourceUrl = prefs.getString(_sourceUrlKey);
      
      if (sourceUrl == null) {
        print('使用默认视频源: $_defaultSourceUrl');
        sourceUrl = _defaultSourceUrl;
        await prefs.setString(_sourceUrlKey, sourceUrl);
      }
      
      print('加载视频源配置: $sourceUrl');
      await fetchSourceConfig(sourceUrl);
    } catch (e) {
      print('加载视频源配置出错: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> fetchSourceConfig(String url) async {
    try {
      state = const AsyncValue.loading();
      print('获取视频源配置: $url');
      
      final config = await _sourceService.fetchSourceConfig(url);
      if (config.sites.isEmpty) {
        throw Exception('视频源配置中没有可用的站点');
      }
      
      state = AsyncValue.data(config);
      print('成功获取视频源配置，共有 ${config.sites.length} 个站点');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sourceUrlKey, url);

      // 恢复之前选中的视频源
      final selectedSourceKey = prefs.getString(_selectedSourceKey);
      VideoSourceConfig selectedSource;
      
      if (selectedSourceKey != null) {
        print('尝试恢复之前选中的视频源: $selectedSourceKey');
        selectedSource = config.sites.firstWhere(
          (source) => source.key == selectedSourceKey,
          orElse: () {
            print('找不到之前选中的视频源，使用第一个站点');
            return config.sites.first;
          },
        );
      } else {
        print('没有之前选中的视频源，使用第一个站点');
        selectedSource = config.sites.first;
      }
      
      await _setSelectedSource(selectedSource);
    } catch (e, stack) {
      print('获取视频源配置失败: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _setSelectedSource(VideoSourceConfig source) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedSourceKey, source.key);
      print('设置选中的视频源: ${source.name} (${source.key})');
    } catch (e) {
      print('保存选中的视频源失败: $e');
    }
  }
} 