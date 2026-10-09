import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonatasks_bai03/main.dart';
import 'package:sonatasks_bai03/screens/task_screen.dart';

Future<void> selectTab(WidgetTester tester, String name) async {
  await tester.tap(
    find
        .descendant(
          of: find.byType(BottomNavigationBar),
          matching: find.text(name),
        )
        .last,
  );
  await tester.pumpAndSettle();
}

Finder get taskScroll => find
    .descendant(of: find.byType(TaskScreen), matching: find.byType(Scrollable))
    .first;

Future<void> showItem(WidgetTester tester, Finder finder) async {
  final state = tester.state<ScrollableState>(taskScroll);
  state.position.jumpTo(0);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(finder, 100, scrollable: taskScroll);
  await tester.pumpAndSettle();
}

Future<void> save(
  WidgetTester tester,
  String title, {
  String description = '',
}) async {
  await showItem(tester, find.byKey(const Key('taskTitle')));
  await tester.enterText(find.byKey(const Key('taskTitle')), title);
  await tester.enterText(find.byKey(const Key('taskDescription')), description);
  final button = find.widgetWithText(ElevatedButton, 'Lưu công việc');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

int pending(WidgetTester tester) {
  final badge = tester.widget<Badge>(find.byKey(const Key('pendingBadge')));
  return int.parse((badge.label! as Text).data!);
}

void main() {
  testWidgets('Home có logo, lời chào và một khung cố định', (tester) async {
    await tester.pumpWidget(const SonaTasksApp());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('schoolLogo')), findsOneWidget);
    expect(
      find.text('TRƯỜNG CAO ĐẲNG CÔNG NGHỆ VÀ QUẢN TRỊ SONADEZI'),
      findsOneWidget,
    );
    expect(find.text('Chào mừng đến với ứng dụng SonaTasks'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byTooltip('Thông báo'), findsOneWidget);
    expect(find.byTooltip('Tài khoản'), findsOneWidget);
    expect(pending(tester), 3);
  });

  testWidgets('Menu chọn đúng ba Screen và About đủ nội dung', (tester) async {
    await tester.pumpWidget(const SonaTasksApp());
    for (final entry in ['Task', 'About', 'Home'].asMap().entries) {
      await selectTab(tester, entry.value);
      final expected = {'Home': 0, 'Task': 1, 'About': 2}[entry.value];
      expect(
        tester
            .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
            .currentIndex,
        expected,
      );
      expect(find.byType(Scaffold), findsOneWidget);
    }
    await selectTab(tester, 'About');
    expect(find.text('Môn Lập trình Mobile với Flutter'), findsOneWidget);
    expect(find.text('Phiên bản 1.0.0'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('Form Task chặn rỗng và khoảng trắng', (tester) async {
    await tester.pumpWidget(const SonaTasksApp());
    await selectTab(tester, 'Task');
    for (final title in ['', '   ']) {
      await save(tester, title);
      expect(find.text('Vui lòng nhập tên công việc.'), findsOneWidget);
      expect(pending(tester), 3);
    }
    await showItem(tester, find.text('5 công việc • 2 đã hoàn thành'));
    expect(find.text('5 công việc • 2 đã hoàn thành'), findsOneWidget);
  });

  testWidgets('Thêm hai Task, xóa form và giữ dữ liệu khi đổi tab', (
    tester,
  ) async {
    await tester.pumpWidget(const SonaTasksApp());
    await selectTab(tester, 'Task');
    await save(tester, '  Ôn tập Flutter  ', description: '  Làm bài 03  ');
    for (final key in ['taskTitle', 'taskDescription']) {
      expect(
        tester.widget<TextField>(find.byKey(Key(key))).controller!.text,
        '',
      );
    }
    await save(tester, 'Nộp bài thực hành');
    expect(pending(tester), 5);
    await selectTab(tester, 'Home');
    await selectTab(tester, 'About');
    await selectTab(tester, 'Task');
    await showItem(tester, find.text('7 công việc • 2 đã hoàn thành'));
    expect(find.text('7 công việc • 2 đã hoàn thành'), findsOneWidget);
    await showItem(tester, find.text('Ôn tập Flutter'));
    expect(find.text('Làm bài 03'), findsOneWidget);
    await showItem(tester, find.text('Nộp bài thực hành'));
    expect(find.text('Nộp bài thực hành'), findsOneWidget);
  });

  testWidgets('Ưu tiên được lưu riêng và form được đặt lại', (tester) async {
    await tester.pumpWidget(const SonaTasksApp());
    await selectTab(tester, 'Task');
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cao').last);
    await tester.pumpAndSettle();
    await save(tester, 'Nộp bài');
    expect(
      tester
          .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
          .value,
      'Bình thường',
    );
    await showItem(tester, find.text('Nộp bài'));
    expect(find.text('Ưu tiên: Cao'), findsOneWidget);
  });

  testWidgets('Checkbox đồng bộ thống kê, badge và bộ lọc', (tester) async {
    await tester.pumpWidget(const SonaTasksApp());
    await selectTab(tester, 'Task');
    final title = find.text('Dựng layout màn hình Home');
    await showItem(tester, title);
    final card = find.ancestor(of: title, matching: find.byType(TaskCard));
    await tester.tap(
      find.descendant(of: card, matching: find.byType(Checkbox)),
    );
    await tester.pumpAndSettle();
    expect(pending(tester), 2);
    expect(
      tester.widget<Text>(title).style!.decoration,
      TextDecoration.lineThrough,
    );
    await showItem(tester, find.text('5 công việc • 3 đã hoàn thành'));
    await showItem(tester, find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    expect(title, findsNothing);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await showItem(tester, title);
    await tester.tap(
      find.descendant(of: card, matching: find.byType(Checkbox)),
    );
    await tester.pumpAndSettle();
    expect(pending(tester), 3);
  });

  testWidgets('Chuông thông báo và Dialog tài khoản hoạt động', (tester) async {
    await tester.pumpWidget(const SonaTasksApp());
    await tester.tap(find.byTooltip('Thông báo'));
    await tester.pumpAndSettle();
    expect(find.text('Bạn có 3 công việc chưa hoàn thành.'), findsOneWidget);
    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Màn hình nhỏ và bàn phím không gây tràn', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SonaTasksApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await selectTab(tester, 'Task');
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    await save(tester, 'Việc trên mobile');
    expect(pending(tester), 4);
    expect(tester.takeException(), isNull);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  test('Danh sách mẫu không chia sẻ đối tượng mutable', () {
    final first = createSampleTasks();
    first[0].isDone = false;
    expect(createSampleTasks()[0].isDone, isTrue);
  });
}
