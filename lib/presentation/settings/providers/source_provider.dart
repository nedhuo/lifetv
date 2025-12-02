import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../domain/media_source/video_source.dart';


part 'source_provider.g.dart';

@riverpod
class VideoSourceNotifier extends _$VideoSourceNotifier {
  static const String _sourceKey = 'video_sources';
  
  @override
  Future<List<VideoSource>> build() async {
    return _loadSources();
  }

  Future<List<VideoSource>> _loadSources() async {
    final prefs = await SharedPreferences.getInstance();
    final sourcesJson = prefs.getString(_sourceKey);
    
    if (sourcesJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> sourcesList = json.decode(sourcesJson);
      return sourcesList
          .map((e) => VideoSource.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveSources(List<VideoSource> sources) async {
    final prefs = await SharedPreferences.getInstance();
    final sourcesJson = json.encode(
      sources.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_sourceKey, sourcesJson);
  }

  Future<void> addSource(VideoSource source) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final sources = [...?state.value];
      
      // 如果是默认源，取消其他源的默认状态
      if (source.isDefault) {
        sources.forEach((s) {
          if (s.isDefault) {
            s = s.copyWith(isDefault: false);
          }
        });
      }
      
      sources.add(source);
      await _saveSources(sources);
      return sources;
    });
  }

  Future<void> updateSource(VideoSource source) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final sources = [...?state.value];
      final index = sources.indexWhere((s) => s.id == source.id);
      
      if (index == -1) {
        throw Exception('视频源不存在');
      }
      
      // 如果是默认源，取消其他源的默认状态
      if (source.isDefault) {
        sources.forEach((s) {
          if (s.id != source.id && s.isDefault) {
            s = s.copyWith(isDefault: false);
          }
        });
      }
      
      sources[index] = source;
      await _saveSources(sources);
      return sources;
    });
  }

  Future<void> deleteSource(String sourceId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final sources = [...?state.value];
      sources.removeWhere((s) => s.id == sourceId);
      await _saveSources(sources);
      return sources;
    });
  }

  Future<void> setDefaultSource(String sourceId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final sources = [...?state.value];
      for (var i = 0; i < sources.length; i++) {
        sources[i] = sources[i].copyWith(
          isDefault: sources[i].id == sourceId,
        );
      }
      await _saveSources(sources);
      return sources;
    });
  }

  VideoSource? getDefaultSource() {
    return state.value?.firstWhere(
      (s) => s.isDefault,
      orElse: () => state.value!.first,
    );
  }
}

@riverpod
class VideoSourceService extends _$VideoSourceService {
  @override
  VideoSourceService build() {
    throw UnimplementedError();
  }
}