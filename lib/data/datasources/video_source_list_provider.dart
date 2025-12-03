import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/dtos/video_source_entity.dart';
import '../../data/repositories/video_source_service.dart';

final videoSourceListProvider = AsyncNotifierProvider<VideoSourceListNotifier, List<VideoSourceEntity>>(() {
  return VideoSourceListNotifier();
});

class VideoSourceListNotifier extends AsyncNotifier<List<VideoSourceEntity>> {
  late final VideoSourceService _service;
  List<VideoSourceEntity> _memorySources = [];

  @override
  Future<List<VideoSourceEntity>> build() async {
    _service = ref.read(videoSourceServiceProvider);
    
    // 初始化默认源
    _memorySources = await _service.initializeDefaultSource([]);
    return _memorySources;
  }

  Future<List<VideoSourceEntity>> _loadSources() async {
    return _memorySources;
  }

  Future<void> addSource({
    required String name,
    required String url,
  }) async {
    state = const AsyncValue.loading();
    try {
      final source = VideoSourceEntity.create(
        name: name,
        url: url,
      );
      _memorySources = await _service.addSource(_memorySources, source);
      state = AsyncValue.data(_memorySources);
    } catch (e) {
      print('添加视频源失败: $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> removeSource(String key) async {
    state = const AsyncValue.loading();
    try {
      _memorySources = await _service.removeSource(_memorySources, key);
      state = AsyncValue.data(_memorySources);
    } catch (e) {
      print('删除视频源失败: $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> switchSource(String key) async {
    state = const AsyncValue.loading();
    try {
      _memorySources = await _service.setActiveSource(_memorySources, key);
      state = AsyncValue.data(_memorySources);
    } catch (e) {
      print('切换视频源失败: $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateSource(VideoSourceEntity source) async {
    state = const AsyncValue.loading();
    try {
      _memorySources = await _service.updateSource(_memorySources, source);
      state = AsyncValue.data(_memorySources);
    } catch (e) {
      print('更新视频源失败: $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<VideoSourceEntity?> getActiveSource() async {
    try {
      return await _service.getActiveSource(_memorySources);
    } catch (e) {
      print('获取活跃视频源失败: $e');
      return null;
    }
  }
} 