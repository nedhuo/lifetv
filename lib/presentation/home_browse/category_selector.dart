import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/repositories/video_source_service.dart';
import '../../domain/media_source/video_source_config.dart';
import '../../data/datasources/video_source_list_provider.dart';
import '../../data/dtos/video_source_entity.dart';

final selectedSourceProvider = StateProvider<VideoSourceEntity?>((ref) => null);

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final selectedSource = ref.watch(selectedSourceProvider);
  if (selectedSource == null) return [];

  final sourceService = ref.watch(videoSourceServiceProvider);
  final categories = await sourceService.fetchCategories(selectedSource);
  
  // 处理分类数据
  return categories.map((category) {
    return {
      'id': category['type_id']?.toString() ?? category['id']?.toString() ?? '',
      'name': category['type_name']?.toString() ?? category['name']?.toString() ?? '',
    };
  }).toList();
});

class CategorySelector extends HookConsumerWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 40.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1, // +1 for "全部" category
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final category = isAll ? null : categories[index - 1];
              final isSelected = isAll
                  ? selectedCategory == null
                  : selectedCategory == category?['id'];

              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ChoiceChip(
                  label: Text(
                    isAll ? 'category.all'.tr() : category?['name'] ?? '',
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(selectedCategoryProvider.notifier).state =
                          isAll ? null : category?['id'];
                    }
                  },
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) {
        print('加载分类失败: $error');
        return const SizedBox.shrink();
      },
    );
  }
} 