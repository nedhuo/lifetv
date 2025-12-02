import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/datasources/video_source_list_provider.dart';
import '../../data/dtos/video_source_entity.dart';

class VideoSourceListPage extends HookConsumerWidget {
  const VideoSourceListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesAsync = ref.watch(videoSourceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('视频源管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddSourceDialog(context, ref),
          ),
        ],
      ),
      body: sourcesAsync.when(
        data: (sources) => ListView.builder(
          itemCount: sources.length,
          itemBuilder: (context, index) {
            final source = sources[index];
            return ListTile(
              title: Text(source.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(source.url),
                  Text(
                    '更新时间: ${_formatDateTime(source.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              isThreeLine: true,
              leading: source.isDefault
                  ? const Icon(Icons.star, color: Colors.amber)
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (source.isActive)
                    const Icon(Icons.check_circle, color: Colors.green),
                  if (!source.isDefault)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context, ref, source),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditSourceDialog(context, ref, source),
                  ),
                ],
              ),
              onTap: source.isActive
                  ? null
                  : () => _switchSource(context, ref, source),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('加载失败: $error'),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showAddSourceDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    bool isLoading = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加视频源'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  hintText: '请输入视频源名称',
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: '请输入视频源URL',
                ),
                enabled: !isLoading,
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (nameController.text.isNotEmpty &&
                          urlController.text.isNotEmpty) {
                        setState(() => isLoading = true);
                        try {
                          await ref.read(videoSourceListProvider.notifier).addSource(
                                name: nameController.text,
                                url: urlController.text,
                              );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('添加成功')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('添加失败: $e')),
                            );
                            setState(() => isLoading = false);
                          }
                        }
                      }
                    },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditSourceDialog(
    BuildContext context,
    WidgetRef ref,
    VideoSourceEntity source,
  ) async {
    final nameController = TextEditingController(text: source.name);
    final urlController = TextEditingController(text: source.url);
    bool isLoading = false;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑视频源'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  hintText: '请输入视频源名称',
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: '请输入视频源URL',
                ),
                enabled: !isLoading,
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (nameController.text.isNotEmpty &&
                          urlController.text.isNotEmpty) {
                        setState(() => isLoading = true);
                        try {
                          final updatedSource = VideoSourceEntity()
                            ..id = source.id
                            ..name = nameController.text
                            ..url = urlController.text
                            ..isDefault = source.isDefault
                            ..isActive = source.isActive
                            ..type = source.type
                            ..createdAt = source.createdAt
                            ..updatedAt = DateTime.now();
                          await ref
                              .read(videoSourceListProvider.notifier)
                              .updateSource(updatedSource);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('更新成功')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('更新失败: $e')),
                            );
                            setState(() => isLoading = false);
                          }
                        }
                      }
                    },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _switchSource(
    BuildContext context,
    WidgetRef ref,
    VideoSourceEntity source,
  ) async {
    try {
      await ref.read(videoSourceListProvider.notifier).switchSource(source.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已切换到视频源: ${source.name}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('切换失败: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    VideoSourceEntity source,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除视频源"${source.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(videoSourceListProvider.notifier)
                    .removeSource(source.id);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('删除成功')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('删除失败: $e')),
                  );
                }
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
} 