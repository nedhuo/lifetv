import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../source/application/providers/video_source_provider.dart';
import '../../../source/domain/services/video_source_service.dart';

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final categoriesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final selectedSource = ref.watch(selectedSourceProvider);
  if (selectedSource == null) return [];

  final sourceService = ref.watch(videoSourceServiceProvider);
  return sourceService.fetchCategories(selectedSource);
});

class CategorySelector extends ConsumerWidget {
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
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
} 