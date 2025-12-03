class TvboxSiteEntity {
  int id = 0;
  
  String key;
  String name;
  int type;
  String api;
  bool searchable;
  bool quickSearch;
  bool filterable;
  String? ext;
  int playerType;
  DateTime updatedAt;

  TvboxSiteEntity({
    this.id = 0,
    required this.key,
    required this.name,
    required this.type,
    required this.api,
    required this.searchable,
    required this.quickSearch,
    required this.filterable,
    this.ext,
    required this.playerType,
    required this.updatedAt,
  });

  factory TvboxSiteEntity.fromTvboxSite(dynamic site) {
    return TvboxSiteEntity(
      key: site.key,
      name: site.name,
      type: site.type,
      api: site.api,
      searchable: site.searchable,
      quickSearch: site.quickSearch,
      filterable: site.filterable,
      ext: site.ext,
      playerType: site.playerType,
      updatedAt: DateTime.now(),
    );
  }
} 