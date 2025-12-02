import 'dart:math';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/video_source_config.dart';

part 'video_source_entity.g.dart';

@Name("VideoSource")
@collection
class VideoSourceEntity {
  static final _random = Random();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  final String key;

  @Index(unique: true, replace: true)
  final String name;

  @Index(unique: true, replace: true)
  final String url;

  final String api;
  final String type;
  final String? group;
  final String? logo;
  final String? ua;
  final String? referer;
  final String? origin;
  final String? cookie;
  final String? proxy;
  final String? header;
  final String? click;
  final String? desc;
  final String? ext;
  final String? jar;
  final String? categories;
  final String? searchable;
  final String? quickSearch;
  final String? filterable;
  final String? playerType;
  final String? searchUrl;
  final String? playUrl;

  @Index()
  final int timestamp;

  bool isDefault;
  bool isActive;

  DateTime createdAt;
  DateTime updatedAt;

  VideoSourceEntity({
    required this.key,
    required this.name,
    required this.url,
    required this.api,
    required this.type,
    this.group,
    this.logo,
    this.ua,
    this.referer,
    this.origin,
    this.cookie,
    this.proxy,
    this.header,
    this.click,
    this.desc,
    this.ext,
    this.jar,
    this.categories,
    this.searchable,
    this.quickSearch,
    this.filterable,
    this.playerType,
    this.searchUrl,
    this.playUrl,
    this.isDefault = false,
    this.isActive = false,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch,
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  factory VideoSourceEntity.fromConfig(VideoSourceConfig config) {
    return VideoSourceEntity(
      key: config.key,
      name: config.name,
      url: config.url,
      api: config.api,
      type: config.type.toString(),
      group: config.group,
      logo: config.logo,
      ua: config.ua,
      referer: config.referer,
      origin: config.origin,
      cookie: config.cookie,
      proxy: config.proxy,
      header: config.header,
      click: config.click,
      desc: config.desc,
      ext: config.ext,
      jar: config.jar,
      categories: config.categories,
      searchable: config.searchable.toString(),
      quickSearch: config.quickSearch.toString(),
      filterable: config.filterable.toString(),
      playerType: config.playerType.toString(),
      searchUrl: config.searchUrl,
      playUrl: config.playUrl,
    );
  }

  factory VideoSourceEntity.create({
    required String name,
    required String url,
    String type = 'api',
  }) {
    final key = _random.nextInt(1000000).toString();
    
    return VideoSourceEntity(
      key: key,
      name: name,
      url: url,
      api: '',
      type: type,
    );
  }

  @override
  String toString() => 'VideoSourceEntity(key: $key, name: $name)';
} 