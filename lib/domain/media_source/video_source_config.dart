import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_source_config.freezed.dart';
part 'video_source_config.g.dart';

@freezed
class VideoSourceConfig with _$VideoSourceConfig {
  const factory VideoSourceConfig({
    required String key,
    required String name,
    required String api,
    required String url,
    required int type,
    String? group,
    String? logo,
    String? ua,
    String? referer,
    String? origin,
    String? cookie,
    String? proxy,
    String? header,
    String? click,
    String? desc,
    String? ext,
    String? jar,
    String? categories,
    @Default(true) bool searchable,
    @Default(true) bool quickSearch,
    @Default(true) bool filterable,
    @Default(1) int playerType,
    String? searchUrl,
    String? playUrl,
  }) = _VideoSourceConfig;

  factory VideoSourceConfig.fromJson(Map<String, dynamic> json) =>
      _$VideoSourceConfigFromJson(json);
}

@freezed
class VideoSourceResponse with _$VideoSourceResponse {
  const factory VideoSourceResponse({
    required List<VideoSourceConfig> sites,
    required List<Map<String, dynamic>> parses,
    required List<Map<String, dynamic>> lives,
    String? spider,
    String? wallpaper,
  }) = _VideoSourceResponse;

  factory VideoSourceResponse.fromJson(Map<String, dynamic> json) =>
      _$VideoSourceResponseFromJson(json);
} 