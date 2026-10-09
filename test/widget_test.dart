import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_01/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Roboto');
    font.addFont(
      File('test/fonts/ui_test.ttf')
          .readAsBytes()
          .then((bytes) => ByteData.sublistView(bytes)),
    );
    await font.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(
      File('test/fonts/icons_test.otf')
          .readAsBytes()
          .then((bytes) => ByteData.sublistView(bytes)),
    );
    await icons.load();
  });
  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Home không tràn ở $size với cỡ chữ $scale', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(const SonaTasksApp());
        await tester.pumpAndSettle();
        expect(find.text('SonaTasks'), findsOneWidget);
        expect(find.text('Tổng công việc'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.text('Chuẩn bị bài học tiếp theo'),
          200,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();
        expect(find.text('Chuẩn bị bài học tiếp theo'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('Nút thêm và màn hình giới thiệu', (tester) async {
    await tester.pumpWidget(const SonaTasksApp());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chức năng thêm công việc'), findsOneWidget);
    await tester.tap(find.byTooltip('Giới thiệu ứng dụng'));
    await tester.pumpAndSettle();
    expect(find.text('Giới thiệu'), findsOneWidget);
    await tester.tap(find.text('Về trang chủ'));
    await tester.pumpAndSettle();
    expect(find.text('Công việc của bạn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Xuất ảnh giao diện từ Flutter', (tester) async {
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = true);
    final key = GlobalKey();
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final entry in {
      'home_doc': const Size(390, 1100),
      'home_ngang': const Size(844, 500),
    }.entries) {
      tester.view.physicalSize = entry.value;
      await tester.pumpWidget(
        RepaintBoundary(key: key, child: const SonaTasksApp()),
      );
      await tester.pumpAndSettle();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('screenshots').create(recursive: true);
        await File('screenshots/${entry.key}.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    debugDisableShadows = true;
  });
}
