import 'package:freezed_annotation/freezed_annotation.dart';

part 'tvbox_config.freezed.dart';
part 'tvbox_config.g.dart';

@freezed
class TvboxConfig with _$TvboxConfig {
  const factory TvboxConfig({
    required String spider,
    required String wallpaper,
    required List<TvboxSite> sites,
    required List<TvboxParse> parses,
  }) = _TvboxConfig;

  factory TvboxConfig.fromJson(Map<String, dynamic> json) =>
      _$TvboxConfigFromJson(json);
}

@freezed
class TvboxSite with _$TvboxSite {
  const factory TvboxSite({
    required String key,
    required String name,
    required int type,
    required String api,
    @Default(false) bool searchable,
    @Default(false) bool quickSearch,
    @Default(false) bool filterable,
    String? ext,
    @Default(1) int playerType,
  }) = _TvboxSite;

  factory TvboxSite.fromJson(Map<String, dynamic> json) =>
      _$TvboxSiteFromJson(json);
}

@freezed
class TvboxParse with _$TvboxParse {
  const factory TvboxParse({
    required String name,
    required int type,
    required String url,
    Map<String, dynamic>? ext,
  }) = _TvboxParse;

  factory TvboxParse.fromJson(Map<String, dynamic> json) =>
      _$TvboxParseFromJson(json);
} 