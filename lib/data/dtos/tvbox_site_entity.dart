import 'package:isar/isar.dart';

part 'tvbox_site_entity.g.dart';

@collection
class TvboxSiteEntity {
  Id id = Isar.autoIncrement;
  
  @Index(unique: true)
  late String key;
  
  late String name;
  late int type;
  late String api;
  late bool searchable;
  late bool quickSearch;
  late bool filterable;
  String? ext;
  late int playerType;
  late DateTime updatedAt;

  TvboxSiteEntity();

  factory TvboxSiteEntity.fromTvboxSite(dynamic site) {
    final entity = TvboxSiteEntity()
      ..key = site.key
      ..name = site.name
      ..type = site.type
      ..api = site.api
      ..searchable = site.searchable
      ..quickSearch = site.quickSearch
      ..filterable = site.filterable
      ..ext = site.ext
      ..playerType = site.playerType
      ..updatedAt = DateTime.now();
    return entity;
  }
} 