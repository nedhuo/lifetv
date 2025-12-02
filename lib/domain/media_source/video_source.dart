import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_source.freezed.dart';
part 'video_source.g.dart';

@freezed
class VideoSource with _$VideoSource {
  const factory VideoSource({
    required String id,
    required String name,
    required String apiUrl,
    String? header,
    @Default(true) bool enabled,
    @Default(false) bool isDefault,
    DateTime? lastUpdated,
  }) = _VideoSource;

  factory VideoSource.fromJson(Map<String, dynamic> json) =>
      _$VideoSourceFromJson(json);
}

@freezed
class VideoCategory with _$VideoCategory {
  const factory VideoCategory({
    required String id,
    required String name,
    required String type,
    @Default([]) List<VideoCategory> children,
  }) = _VideoCategory;

  factory VideoCategory.fromJson(Map<String, dynamic> json) =>
      _$VideoCategoryFromJson(json);
}

@freezed
class VideoDetail with _$VideoDetail {
  const factory VideoDetail({
    required String id,
    required String title,
    required String coverUrl,
    String? description,
    required List<VideoPlayUrl> playUrls,
    String? director,
    String? actors,
    String? area,
    String? year,
    String? status,
    @Default([]) List<String> categories,
  }) = _VideoDetail;

  factory VideoDetail.fromJson(Map<String, dynamic> json) =>
      _$VideoDetailFromJson(json);
}

@freezed
class VideoPlayUrl with _$VideoPlayUrl {
  const factory VideoPlayUrl({
    required String name,
    required String url,
    String? quality,
    @Default(false) bool isM3U8,
  }) = _VideoPlayUrl;

  factory VideoPlayUrl.fromJson(Map<String, dynamic> json) =>
      _$VideoPlayUrlFromJson(json);
}