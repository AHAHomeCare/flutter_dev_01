import 'package:flutter/material.dart';

// Home chỉ chào mừng; biểu mẫu và danh sách nằm ở TaskScreen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/sonadezi_logo.png',
                    key: const Key('schoolLogo'),
                    width: 160,
                    height: 194,
                    fit: BoxFit.contain,
                    semanticLabel: 'Logo Trường Cao đẳng Sonadezi',
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'TRƯỜNG CAO ĐẲNG CÔNG NGHỆ VÀ QUẢN TRỊ SONADEZI',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF315ACB),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Chào mừng đến với ứng dụng SonaTasks',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Chọn Task ở menu dưới để quản lý công việc.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
