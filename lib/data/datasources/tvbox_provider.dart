import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/tvbox_site_entity.dart';
import '../../domain/services/tvbox_service.dart';
import '../../../database/providers/isar_provider.dart';

final tvboxSitesProvider = AsyncNotifierProvider<TvboxSitesNotifier, List<TvboxSiteEntity>>(() {
  return TvboxSitesNotifier();
});

class TvboxSitesNotifier extends AsyncNotifier<List<TvboxSiteEntity>> {
  static const defaultConfigUrl = 'https://pandown.pro/tvbox/tvbox.json';

  @override
  Future<List<TvboxSiteEntity>> build() async {
    final isar = ref.watch(isarProvider);
    return _loadSites(isar);
  }

  Future<List<TvboxSiteEntity>> _loadSites(Isar isar) async {
    final service = ref.read(tvboxServiceProvider);
    return await service.getAllSites(isar);
  }

  Future<void> refreshSites() async {
    final isar = ref.read(isarProvider);
    final service = ref.read(tvboxServiceProvider);
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await service.updateSites(defaultConfigUrl, isar);
      return await _loadSites(isar);
    });
  }

  Future<void> updateFromUrl(String url) async {
    final isar = ref.read(isarProvider);
    final service = ref.read(tvboxServiceProvider);
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await service.updateSites(url, isar);
      return await _loadSites(isar);
    });
  }
} 