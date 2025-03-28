import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/video_grid_view.dart';
import '../widgets/category_selector.dart';
import '../../application/providers/video_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // 首页
        break;
      case 1: // 收藏
        context.go('/favorites');
        break;
      case 2: // 历史
        context.go('/history');
        break;
      case 3: // 视频源
        context.go('/source');
        break;
      case 4: // 设置
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(videoProvider);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemSelected,
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: Text('navigation.home'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.favorite_outline),
                selectedIcon: const Icon(Icons.favorite),
                label: Text('navigation.favorites'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.history_outlined),
                selectedIcon: const Icon(Icons.history),
                label: Text('navigation.history'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.video_library_outlined),
                selectedIcon: const Icon(Icons.video_library),
                label: Text('navigation.source'.tr()),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: Text('navigation.settings'.tr()),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CategorySelector(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: videosAsync.when(
                      data: (videos) => videos.isEmpty
                          ? Center(
                              child: Text(
                                'video.noVideos'.tr(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            )
                          : VideoGridView(videos: videos),
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'video.loadError'.tr(),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => ref.refresh(videoProvider),
                              icon: const Icon(Icons.refresh),
                              label: Text('common.retry'.tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}