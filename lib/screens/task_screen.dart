import 'package:flutter/material.dart';

import '../widgets/add_task_form.dart';

// Kế thừa dữ liệu Bài 02; isDone có thể thay đổi ở Bài 03.
class Task {
  Task(
    this.title,
    this.description, {
    this.isDone = false,
    this.priority = 'Bình thường',
  });
  final String title;
  final String description;
  bool isDone;
  final String priority;
}

// Hàm tạo danh sách mới cho mỗi màn hình, tránh dùng chung Task có thể sửa.
List<Task> createSampleTasks() => <Task>[
  Task('Ôn tập Dart cơ bản', 'Biến, kiểu dữ liệu và hàm', isDone: true),
  Task('Dựng layout màn hình Home', 'Thực hành Row, Column và Expanded'),
  Task('Hoàn thành bài tập Flutter', 'Kiểm tra giao diện trên điện thoại'),
  Task(
    'Đọc tài liệu về Widget',
    'Tìm hiểu Scaffold và BuildContext',
    isDone: true,
  ),
  Task('Chuẩn bị bài học tiếp theo', 'Widget, Form và quản lý trạng thái'),
];

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key, required this.onPendingChanged});
  final ValueChanged<int> onPendingChanged;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final List<Task> _tasks = createSampleTasks();
  bool _onlyPending = false;

  void _notifyPendingCount() {
    widget.onPendingChanged(_tasks.where((task) => !task.isDone).length);
  }

  void _addTask(String title, String description, String priority) {
    setState(() {
      _tasks.add(Task(title, description, priority: priority));
    });
    _notifyPendingCount();
  }

  void _toggleTask(Task task, bool? value) {
    setState(() {
      task.isDone = value ?? false;
    });
    _notifyPendingCount();
  }

  @override
  Widget build(BuildContext context) {
    final done = _tasks.where((task) => task.isDone).length;
    final visibleTasks = _onlyPending
        ? _tasks.where((task) => !task.isDone).toList()
        : _tasks;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Thêm công việc',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        AddTaskForm(onAdd: _addTask),
        const SizedBox(height: 24),
        // Giữ StatCard và cách bố trí responsive đã học ở Bài 02.
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              StatCard(
                label: 'Tổng công việc',
                value: _tasks.length,
                icon: Icons.assignment_outlined,
                color: const Color(0xFF315ACB),
              ),
              StatCard(
                label: 'Đã xong',
                value: done,
                icon: Icons.check_circle_outline,
                color: const Color(0xFF16815D),
              ),
              StatCard(
                label: 'Chưa xong',
                value: _tasks.length - done,
                icon: Icons.schedule,
                color: const Color(0xFFAA6514),
              ),
            ];
            if (constraints.maxWidth >= 600 &&
                MediaQuery.textScalerOf(context).scale(14) <= 21) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            }
            return Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  cards[i],
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Danh sách công việc',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text('${_tasks.length} công việc • $done đã hoàn thành'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Chỉ hiện việc chưa hoàn thành'),
          value: _onlyPending,
          onChanged: (value) {
            setState(() {
              _onlyPending = value;
            });
          },
        ),
        if (visibleTasks.isEmpty)
          const Text('Không có công việc phù hợp với bộ lọc.'),
        for (final task in visibleTasks)
          TaskCard(
            key: ObjectKey(task),
            task: task,
            onChanged: (value) => _toggleTask(task, value),
          ),
        const SizedBox(height: 16),
        const Text(
          'Dữ liệu lưu trong RAM. Khởi động lại sẽ trở về 5 công việc mẫu.',
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleSmall),
          ),
          const SizedBox(width: 8),
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, required this.onChanged});
  final Task task;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = task.isDone
        ? const Color(0xFF16815D)
        : const Color(0xFF315ACB);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack đặt chấm trạng thái lên góc biểu tượng công việc.
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.description_outlined, color: color),
                ),
                if (task.isDone)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF16815D),
                      size: 18,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (task.description.isNotEmpty) Text(task.description),
                  Text('Ưu tiên: ${task.priority}'),
                  const SizedBox(height: 8),
                  Text(
                    task.isDone ? 'Đã xong' : 'Chưa xong',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: task.isDone,
              onChanged: onChanged,
              semanticLabel: 'Hoàn thành ${task.title}',
            ),
          ],
        ),
      ),
    );
  }
}
