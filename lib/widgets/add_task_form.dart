import 'package:flutter/material.dart';

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key, required this.onAdd});
  // Callback chuyển dữ liệu từ form tới màn hình cha.
  final Future<void> Function(String title, String description, String priority)
  onAdd;
  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Bình thường';

  bool _saving = false;

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên công việc.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onAdd(title, description, _priority);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không xác nhận được việc lưu. Hãy tải lại danh sách trước khi thử lại.',
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      _priority = 'Bình thường';
    });
    _titleController.clear();
    _descriptionController.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã lưu công việc.')));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('taskTitle'),
          enabled: !_saving,
          controller: _titleController,
          maxLength: 100,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Tên công việc',
            hintText: 'Ví dụ: Ôn tập Flutter',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('taskDescription'),
          enabled: !_saving,
          controller: _descriptionController,
          maxLength: 500,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Mô tả',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Độ ưu tiên'),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButton<String>(
                value: _priority,
                isExpanded: true,
                items: ['Thấp', 'Bình thường', 'Cao'].map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _priority = value;
                          });
                        }
                      },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _saving ? null : _saveTask,
          child: Text(_saving ? 'Đang lưu...' : 'Lưu công việc'),
        ),
      ],
    );
  }
}
