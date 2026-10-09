import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sonatasks_bai03/main.dart';
import 'package:sonatasks_bai03/screens/task_screen.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android Home Task About và thêm hai công việc', (tester) async {
    // Nhập liệu tự động qua kênh kiểm thử; bố cục bàn phím có widget test riêng.
    tester.testTextInput.register();
    addTearDown(tester.testTextInput.unregister);
    final screenshotKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(key: screenshotKey, child: const SonaTasksApp()),
    );
    await tester.pumpAndSettle();
    Future<void> screenshot(String name) async {
      await tester.pumpAndSettle();
      final boundary =
          screenshotKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      binding.reportData ??= <String, dynamic>{};
      binding.reportData!['screenshots'] ??= <dynamic>[];
      (binding.reportData!['screenshots'] as List<dynamic>).add({
        'screenshotName': name,
        'bytes': bytes!.buffer.asUint8List().toList(),
      });
      image.dispose();
      debugPrint('Ảnh kiểm thử: $name');
    }

    await screenshot('01_home');

    Future<void> tab(String name) async {
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

    Future<void> save(String title, String description) async {
      final scroll = find
          .descendant(
            of: find.byType(TaskScreen),
            matching: find.byType(Scrollable),
          )
          .first;
      tester.state<ScrollableState>(scroll).position.jumpTo(0);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('taskTitle')), title);
      await tester.enterText(
        find.byKey(const Key('taskDescription')),
        description,
      );
      final button = find.widgetWithText(ElevatedButton, 'Lưu công việc');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    await tab('Task');
    await screenshot('02_task_form');
    await save('   ', '');
    expect(find.text('Vui lòng nhập tên công việc.'), findsOneWidget);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await screenshot('03_task_validation');
    await save('Ôn tập Flutter Bài 03', 'Thực hành Home, Task và About');
    await save('Nộp bài thực hành', 'Kiểm tra form và Checkbox');
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('taskTitle')))
          .controller!
          .text,
      isEmpty,
    );
    await tab('About');
    await screenshot('04_about');
    await tab('Home');
    await tab('Task');
    final scroll = find
        .descendant(
          of: find.byType(TaskScreen),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Ôn tập Flutter Bài 03'),
      160,
      scrollable: scroll,
    );
    await tester.pumpAndSettle();
    expect(find.text('Ôn tập Flutter Bài 03'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Nộp bài thực hành'),
      100,
      scrollable: scroll,
    );
    await tester.pumpAndSettle();
    await screenshot('05_task_after_two_added');
    final card = find.ancestor(
      of: find.text('Nộp bài thực hành'),
      matching: find.byType(TaskCard),
    );
    await tester.tap(
      find.descendant(of: card, matching: find.byType(Checkbox)),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<Badge>(find.byKey(const Key('pendingBadge'))).label is Text,
      isTrue,
    );
    expect(
      (tester.widget<Badge>(find.byKey(const Key('pendingBadge'))).label!
              as Text)
          .data,
      '4',
    );
    await screenshot('06_task_checkbox');
    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await screenshot('07_profile');
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();
  });
}
