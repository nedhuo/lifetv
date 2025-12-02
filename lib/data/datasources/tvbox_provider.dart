import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/dtos/tvbox_site_entity.dart';

final tvboxSitesProvider = AsyncNotifierProvider<TvboxSitesNotifier, List<TvboxSiteEntity>>(() {
  return TvboxSitesNotifier();
});

class TvboxSitesNotifier extends AsyncNotifier<List<TvboxSiteEntity>> {
  static const defaultConfigUrl = 'https://pandown.pro/tvbox/tvbox.json';

  @override
  Future<List<TvboxSiteEntity>> build() async {
    return [];
  }

  Future<void> refreshSites() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return [];
    });
  }

  Future<void> updateFromUrl(String url) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return [];
    });
  }
} 