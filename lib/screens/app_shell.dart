import 'package:flutter/material.dart';

import 'about_screen.dart';
import 'home_screen.dart';
import 'task_screen.dart';

// Chỉ khung chung có Scaffold, AppBar và BottomNavigationBar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int currentIndex = 0;
  int _pendingCount = createSampleTasks().where((t) => !t.isDone).length;

  void _selectScreen(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      currentIndex = index;
    });
  }

  void _updatePendingCount(int value) {
    setState(() {
      _pendingCount = value;
    });
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Bạn có $_pendingCount công việc chưa hoàn thành.'),
        ),
      );
  }

  void _showProfile() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tài khoản'),
        content: const Text(
          'Sinh viên SonaTasks\nMôn Lập trình Mobile với Flutter',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const HomeScreen(),
      TaskScreen(onPendingChanged: _updatePendingCount),
      const AboutScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('SonaTasks'),
        actions: [
          IconButton(
            tooltip: 'Thông báo',
            onPressed: _showNotifications,
            icon: Badge(
              key: const Key('pendingBadge'),
              isLabelVisible: _pendingCount > 0,
              label: Text('$_pendingCount'),
              child: const Icon(Icons.notifications_none),
            ),
          ),
          IconButton(
            tooltip: 'Tài khoản',
            onPressed: _showProfile,
            icon: const Icon(Icons.account_circle),
          ),
        ],
      ),
      // IndexedStack giữ State và dữ liệu của TaskScreen khi đổi tab.
      body: SafeArea(
        child: IndexedStack(index: currentIndex, children: screens),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _selectScreen,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Task'),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            activeIcon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
    );
  }
}
