import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../application/providers/video_source_provider.dart';
import '../../domain/models/video_source_config.dart';

class SourcePage extends ConsumerStatefulWidget {
  const SourcePage({super.key});

  @override
  ConsumerState<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends ConsumerState<SourcePage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addSource() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(videoSourceConfigProvider.notifier)
          .fetchSourceConfig(_urlController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('source.addSuccess').tr()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('source.addError').tr(),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceConfigAsync = ref.watch(videoSourceConfigProvider);
    final selectedSource = ref.watch(selectedSourceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('source.title').tr(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 添加新视频源表单
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'source.urlLabel'.tr(),
                      hintText: 'source.urlHint'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'source.urlRequired'.tr();
                      }
                      try {
                        Uri.parse(value);
                        return null;
                      } catch (e) {
                        return 'source.urlInvalid'.tr();
                      }
                    },
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addSource,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text('source.add').tr(),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // 视频源列表
            Text(
              'source.currentSources',
              style: Theme.of(context).textTheme.titleLarge,
            ).tr(),
            SizedBox(height: 16.h),
            sourceConfigAsync.when(
              data: (config) {
                if (config == null || config.sites.isEmpty) {
                  return Center(
                    child: Text('source.noSources').tr(),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: config.sites.length,
                  itemBuilder: (context, index) {
                    final source = config.sites[index];
                    final isSelected = selectedSource?.key == source.key;
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.play_circle_outline,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        title: Text(source.name),
                        subtitle: Text(source.api),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          ref.read(selectedSourceProvider.notifier).state = source;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'source.selected'.tr(namedArgs: {'name': source.name}),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'source.loadError',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ).tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}