import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/models/video_source.dart';

class SourceFormDialog extends StatefulWidget {
  final VideoSource? source;

  const SourceFormDialog({
    super.key,
    this.source,
  });

  @override
  State<SourceFormDialog> createState() => _SourceFormDialogState();
}

class _SourceFormDialogState extends State<SourceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _apiUrlController;
  late TextEditingController _headerController;
  late bool _enabled;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.source?.name);
    _apiUrlController = TextEditingController(text: widget.source?.apiUrl);
    _headerController = TextEditingController(text: widget.source?.header);
    _enabled = widget.source?.enabled ?? true;
    _isDefault = widget.source?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiUrlController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final source = VideoSource(
        id: widget.source?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        apiUrl: _apiUrlController.text,
        header: _headerController.text.isEmpty ? null : _headerController.text,
        enabled: _enabled,
        isDefault: _isDefault,
        lastUpdated: DateTime.now(),
      );
      Navigator.of(context).pop(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.source == null ? '添加视频源' : '编辑视频源'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名称',
                  hintText: '请输入视频源名称',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入名称';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _apiUrlController,
                decoration: const InputDecoration(
                  labelText: 'API地址',
                  hintText: '请输入API地址',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入API地址';
                  }
                  if (!Uri.tryParse(value)!.isAbsolute) {
                    return '请输入有效的URL';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _headerController,
                decoration: const InputDecoration(
                  labelText: '请求头',
                  hintText: '可选，请输入请求头',
                ),
              ),
              SizedBox(height: 16.h),
              SwitchListTile(
                title: const Text('启用'),
                value: _enabled,
                onChanged: (value) {
                  setState(() {
                    _enabled = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('设为默认'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _submitForm,
          child: const Text('确定'),
        ),
      ],
    );
  }
}