import 'package:flutter/material.dart';

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key, required this.onAdd});
  // Callback chuyển dữ liệu từ form tới màn hình cha.
  final void Function(String title, String description, String priority) onAdd;
  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Bình thường';

  void _saveTask() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên công việc.')),
      );
      return;
    }
    widget.onAdd(title, description, _priority);
    setState(() {
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
          controller: _titleController,
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
          controller: _descriptionController,
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
                onChanged: (value) {
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
          onPressed: _saveTask,
          child: const Text('Lưu công việc'),
        ),
      ],
    );
  }
}
