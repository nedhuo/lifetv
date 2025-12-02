import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/video_source_entity.dart';
import '../../domain/services/video_source_service.dart';

final videoSourceListProvider = AsyncNotifierProvider<VideoSourceListNotifier, List<VideoSourceEntity>>(() {
  return VideoSourceListNotifier();
});

class VideoSourceListNotifier extends AsyncNotifier<List<VideoSourceEntity>> {
  late final VideoSourceService _service;
  late final Isar _isar;

  @override
  Future<List<VideoSourceEntity>> build() async {
    _service = ref.read(videoSourceServiceProvider);
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [VideoSourceEntitySchema],
      directory: dir.path,
      maxSizeMiB: 32,
      inspector: false,
    );
    
    // 初始化默认源
    await _service.initializeDefaultSource(_isar);
    return _loadSources();
  }

  Future<List<VideoSourceEntity>> _loadSources() async {
    try {
      return await _service.getAllSources(_isar);
    } catch (e) {
      print('加载视频源失败: $e');
      return [];
    }
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
      await _service.addSource(_isar, source);
      state = AsyncValue.data(await _loadSources());
    } catch (e) {
      print('添加视频源失败: $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> removeSource(String key) async {
    state = const AsyncValue.loading();
    try {
      await _service.removeSource(_isar, key);
      state = AsyncValue.data(await _loadSources());
    } catch (e) {
      print('删除视频源失败: $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> switchSource(String key) async {
    state = const AsyncValue.loading();
    try {
      await _service.setActiveSource(_isar, key);
      state = AsyncValue.data(await _loadSources());
    } catch (e) {
      print('切换视频源失败: $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updateSource(VideoSourceEntity source) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateSource(_isar, source);
      state = AsyncValue.data(await _loadSources());
    } catch (e) {
      print('更新视频源失败: $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<VideoSourceEntity?> getActiveSource() async {
    try {
      return await _service.getActiveSource(_isar);
    } catch (e) {
      print('获取活跃视频源失败: $e');
      return null;
    }
  }
} 