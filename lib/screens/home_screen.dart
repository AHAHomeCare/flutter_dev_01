import 'package:flutter/material.dart';

import 'about_screen.dart';

// Dữ liệu giả lập của Bài 02, chưa cần cơ sở dữ liệu hoặc quản lý trạng thái.
class Task {
  const Task(this.title, this.description, {this.isDone = false});
  final String title;
  final String description;
  final bool isDone;
}

const sampleTasks = <Task>[
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final done = sampleTasks.where((task) => task.isDone).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SonaTasks'),
        actions: [
          IconButton(
            tooltip: 'Giới thiệu ứng dụng',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: SafeArea(
        // Toàn bộ nội dung cuộn được, kể cả khi xoay ngang hoặc tăng cỡ chữ.
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Text(
              'Công việc của bạn',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            const Text('Từng việc nhỏ, mỗi ngày một tiến bộ.'),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final cards = [
                  StatCard(
                    label: 'Tổng công việc',
                    value: sampleTasks.length,
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
                    value: sampleTasks.length - done,
                    icon: Icons.schedule,
                    color: const Color(0xFFAA6514),
                  ),
                ];
                // Màn hình ngang có đủ chỗ: chia đều chiều rộng bằng Expanded.
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
                // Điện thoại nhỏ: xếp dọc để nhãn thống kê không bị ép hẹp.
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
            Text('${sampleTasks.length} công việc mẫu • $done đã hoàn thành'),
            const SizedBox(height: 12),
            for (final task in sampleTasks) TaskCard(task: task),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Thêm công việc',
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Bài 02 thực hành layout. Chức năng thêm công việc sẽ thực hiện ở bài sau.',
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
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
  const TaskCard({super.key, required this.task});
  final Task task;

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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(task.description),
                  const SizedBox(height: 8),
                  Text(
                    task.isDone ? 'Đã xong' : 'Chưa xong',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
