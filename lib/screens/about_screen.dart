import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.task_alt, size: 72, color: Color(0xFF315ACB)),
        const SizedBox(height: 20),
        Text(
          'SonaTasks',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        const Text(
          'Môn Lập trình Mobile với Flutter',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text('Phiên bản 1.0.0', textAlign: TextAlign.center),
        const SizedBox(height: 24),
        const Text(
          'Bài 03 kế thừa Bài 02: điều hướng Home, Task, About; '
          'biểu mẫu thêm công việc và quản lý trạng thái bằng setState.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Dữ liệu chỉ lưu trong bộ nhớ. Khởi động lại ứng dụng '
          'sẽ trở về 5 công việc mẫu của Bài 02.',
        ),
      ],
    );
  }
}
