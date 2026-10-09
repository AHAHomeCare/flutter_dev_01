import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giới thiệu')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.task_alt, size: 72, color: Color(0xFF315ACB)),
            const SizedBox(height: 20),
            Text(
              'SonaTasks',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Ứng dụng mẫu trong môn Lập trình Mobile với Flutter tại Sonadezi. Bài 02 thực hành bố cục màn hình Home với dữ liệu công việc giả lập.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Mục tiêu: sử dụng Row, Column, Container, Padding, Expanded và Stack; bố trí giao diện phù hợp với màn hình nhỏ và màn hình ngang.',
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
