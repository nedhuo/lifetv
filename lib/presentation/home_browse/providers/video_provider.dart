import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/video.dart';
import '../category_selector.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final videoProvider = FutureProvider.autoDispose<List<Video>>((ref) async {
  final selectedSource = ref.watch(selectedSourceProvider);
  if (selectedSource == null) {
    return [];
  }

  final videoService = ref.watch(videoSourceServiceProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  
  try {
    return await videoService.fetchVideos(selectedSource, categoryId: selectedCategory);
  } catch (e) {
    print('获取视频列表失败: $e');
    return [];
  }
});