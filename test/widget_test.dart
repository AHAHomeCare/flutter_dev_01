import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sonatasks_bai09_02/services/account_api.dart';
import 'package:sonatasks_bai09_02/services/sona_task_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonatasks_bai09_02/main.dart';
import 'package:sonatasks_bai09_02/screens/task_screen.dart';

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

SonaTasksApp testApp({AccountApi? accountApi}) {
  final tasks = List.generate(
    5,
    (index) => {
      'id': index + 1,
      'name': index == 1
          ? 'Dựng layout màn hình Home'
          : 'Công việc ${index + 1}',
      'description': null,
      'status': 0,
    },
  );
  http.Response ok(Object data) => http.Response.bytes(
    utf8.encode(
      jsonEncode({
        'result': {'status': 200},
        'data': data,
      }),
    ),
    200,
  );
  final client = MockClient((request) async {
    if (request.method == 'GET') {
      if (request.url.path == '/SonaTask/GetAll') return ok(tasks);
      expect(request.url.path, '/SonaTask/GetTaskByStatus');
      final status = request.url.queryParameters['status'];
      expect(status, anyOf('0', '1'));
      return ok(
        tasks.where((task) => task['status'] == int.parse(status!)).toList(),
      );
    }
    final body =
        jsonDecode(utf8.decode(request.bodyBytes)) as Map<String, dynamic>;
    if (request.url.path.startsWith('/SonaTask/UpdateStatusTask/')) {
      expect(request.method, 'POST');
      final id = int.parse(request.url.pathSegments.last);
      final task = tasks.singleWhere((task) => task['id'] == id);
      expect(body, {'status': task['status'] == 0 ? 1 : 0});
      task['status'] = body['status'] as int;
      return ok(task);
    }
    expect(request.method, 'POST');
    expect(request.url.path, '/SonaTask/CreateTask');
    expect(body.keys, unorderedEquals(['name', 'description']));
    final task = <String, dynamic>{
      'id': tasks.length + 1,
      ...body,
      'status': 0,
    };
    tasks.add(task);
    return ok(task);
  });
  addTearDown(client.close);
  final loginClient = MockClient(
    (_) async => http.Response(
      jsonEncode({
        'result': {'status': 200},
        'data': {
          'tokenType': 'Bearer',
          'accessToken': 'test',
          'expiresIn': 3600,
        },
      }),
      200,
    ),
  );
  addTearDown(loginClient.close);
  return SonaTasksApp(
    api: SonaTaskApi(client, 'http://localhost:5279'),
    accountApi: accountApi ?? AccountApi(loginClient, 'https://example.com'),
  );
}

Future<void> enterCredentials(WidgetTester tester) async {
  await tester.enterText(
    find.byType(TextFormField).first,
    'student@example.com',
  );
  await tester.enterText(find.byType(TextFormField).last, 'example123');
}

Future<void> openSignedInApp(WidgetTester tester) async {
  await tester.pumpWidget(testApp());
  await enterCredentials(tester);
  await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Home có logo, lời chào và một khung cố định', (tester) async {
    await openSignedInApp(tester);
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
    expect(pending(tester), 5);
  });

  testWidgets('Menu chọn đúng ba Screen và About đủ nội dung', (tester) async {
    await openSignedInApp(tester);
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
    await openSignedInApp(tester);
    await selectTab(tester, 'Task');
    for (final title in ['', '   ']) {
      await save(tester, title);
      expect(find.text('Vui lòng nhập tên công việc.'), findsOneWidget);
      expect(pending(tester), 5);
    }
    await showItem(tester, find.text('5 công việc • 0 đã hoàn thành'));
    expect(find.text('5 công việc • 0 đã hoàn thành'), findsOneWidget);
  });

  testWidgets('Thêm hai Task, xóa form và giữ dữ liệu khi đổi tab', (
    tester,
  ) async {
    await openSignedInApp(tester);
    await selectTab(tester, 'Task');
    await save(tester, '  Ôn tập Flutter  ', description: '  Làm bài 03  ');
    for (final key in ['taskTitle', 'taskDescription']) {
      expect(
        tester.widget<TextField>(find.byKey(Key(key))).controller!.text,
        '',
      );
    }
    await save(tester, 'Nộp bài thực hành');
    expect(pending(tester), 7);
    await selectTab(tester, 'Home');
    await selectTab(tester, 'About');
    await selectTab(tester, 'Task');
    await showItem(tester, find.text('7 công việc • 0 đã hoàn thành'));
    expect(find.text('7 công việc • 0 đã hoàn thành'), findsOneWidget);
    await showItem(tester, find.text('Ôn tập Flutter'));
    expect(find.text('Làm bài 03'), findsOneWidget);
    await showItem(tester, find.text('Nộp bài thực hành'));
    expect(find.text('Nộp bài thực hành'), findsOneWidget);
  });

  testWidgets('Ưu tiên được lưu riêng và form được đặt lại', (tester) async {
    await openSignedInApp(tester);
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
    await openSignedInApp(tester);
    await selectTab(tester, 'Task');
    final title = find.text('Dựng layout màn hình Home');
    await showItem(tester, title);
    final card = find.ancestor(of: title, matching: find.byType(TaskCard));
    await tester.tap(
      find.descendant(of: card, matching: find.byType(Checkbox)),
    );
    await tester.pumpAndSettle();
    expect(pending(tester), 4);
    expect(
      tester.widget<Text>(title).style!.decoration,
      TextDecoration.lineThrough,
    );
    await showItem(tester, find.text('5 công việc • 1 đã hoàn thành'));
    await showItem(tester, find.text('Chưa hoàn thành'));
    await tester.tap(find.text('Chưa hoàn thành'));
    await tester.pumpAndSettle();
    expect(title, findsNothing);
    await tester.tap(find.text('Đã hoàn thành'));
    await tester.pumpAndSettle();
    await showItem(tester, title);
    await tester.tap(
      find.descendant(of: card, matching: find.byType(Checkbox)),
    );
    await tester.pumpAndSettle();
    expect(pending(tester), 5);
  });

  testWidgets('Đăng ký, đăng nhập và đăng xuất từ mục tài khoản', (
    tester,
  ) async {
    final calls = <String>[];
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      final body = jsonDecode(request.body);
      expect(body, {'email': 'student@example.com', 'password': 'example123'});
      calls.add(request.url.path);
      final registered = request.url.path.endsWith('/Register');
      final status = registered ? 201 : 200;
      return http.Response(
        jsonEncode({
          'result': {'status': status},
          'data': registered
              ? {'id': 1, 'email': 'student@example.com'}
              : {
                  'tokenType': 'Bearer',
                  'accessToken': 'test',
                  'expiresIn': 3600,
                },
        }),
        status,
      );
    });
    addTearDown(client.close);
    await tester.pumpWidget(
      testApp(accountApi: AccountApi(client, 'https://example.com/api/v1')),
    );
    expect(find.byType(BottomNavigationBar), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập email hợp lệ.'), findsOneWidget);
    expect(calls, isEmpty);
    await tester.tap(find.text('Chưa có tài khoản? Đăng ký'));
    await tester.pumpAndSettle();
    await enterCredentials(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng ký'));
    await tester.pumpAndSettle();
    expect(
      find.text('Đăng ký thành công. Vui lòng đăng nhập.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField).last, 'example123');
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(calls, ['/api/v1/Account/Register', '/api/v1/Account/Login']);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    await tester.tap(find.byTooltip('Thông báo'));
    await tester.pumpAndSettle();
    expect(find.text('Bạn có 5 công việc chưa hoàn thành.'), findsOneWidget);
    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('student@example.com'), findsOneWidget);
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Đăng nhập'), findsOneWidget);
  });

  testWidgets('Màn hình nhỏ và bàn phím không gây tràn', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openSignedInApp(tester);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await selectTab(tester, 'Task');
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    await save(tester, 'Việc trên mobile');
    expect(pending(tester), 6);
    expect(tester.takeException(), isNull);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
