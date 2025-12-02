import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';
part 'video.g.dart';

@freezed
class Video with _$Video {
  const factory Video({
    required String id,
    required String title,
    required String coverUrl,
    required String videoUrl,
    required String description,
    String? category,
    String? score,
    String? year,
    String? area,
    String? director,
    String? actor,
    String? source,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson({
    'id': json['vod_id']?.toString() ?? '',
    'title': json['vod_name']?.toString() ?? '',
    'coverUrl': json['vod_pic']?.toString() ?? '',
    'videoUrl': _parsePlayUrl(json['vod_play_url']?.toString() ?? ''),
    'description': json['vod_content']?.toString() ?? '',
    'category': json['type_name']?.toString(),
    'score': json['vod_score']?.toString(),
    'year': json['vod_year']?.toString(),
    'area': json['vod_area']?.toString(),
    'director': json['vod_director']?.toString(),
    'actor': json['vod_actor']?.toString(),
    'source': json['source']?.toString(),
  });
}

String _parsePlayUrl(String rawUrl) {
  if (rawUrl.isEmpty) return '';
  
  try {
    // 处理多线路播放地址，格式如：线路1$url1#线路2$url2
    final urls = rawUrl.split('#');
    if (urls.isEmpty) return '';
    
    // 取第一个线路的地址
    final parts = urls[0].split('\$');
    if (parts.length < 2) return rawUrl;
    
    return parts[1];
  } catch (e) {
    print('解析播放地址出错: $e');
    return rawUrl;
  }
}