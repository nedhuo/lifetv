import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/media_source/video_source_config.dart';
import '../../../data/repositories/video_source_service.dart';

final selectedSourceProvider = StateProvider<VideoSourceConfig?>((ref) => null);

final videoSourceConfigProvider = AsyncNotifierProvider<VideoSourceConfigNotifier, VideoSourceConfig>(() {
  return VideoSourceConfigNotifier();
});

class VideoSourceConfigNotifier extends AsyncNotifier<VideoSourceConfig> {
  late final VideoSourceService _service;

  @override
  Future<VideoSourceConfig> build() async {
    _service = ref.watch(videoSourceServiceProvider);
    try {
      final response = await _service.fetchSourceConfig(_service.defaultSourceUrl);
      if (response.sites.isEmpty) {
        throw Exception('没有可用的视频源');
      }
      return response.sites.first;
    } catch (e) {
      print('获取默认视频源配置失败: $e');
      // 返回一个备用配置
      return const VideoSourceConfig(
        key: 'default',
        name: '默认源',
        api: 'https://api.example.com',
        url: 'https://example.com',
        type: 0,
      );
    }
  }
} 