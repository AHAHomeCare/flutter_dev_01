# Hướng dẫn sinh viên thực hành Bài 02 Layout trong Flutter

**Môn học:** Lập trình Mobile với Flutter

**Ứng dụng:** SonaTasks

**Thời lượng gợi ý:** 4 giờ

Sinh viên tự tạo project và nhập mã theo thứ tự để xây dựng màn hình Home có thống kê, danh sách công việc giả lập và nút thêm. Sau phần bắt buộc, sinh viên có thể làm thêm bố cục ngang và màn hình giới thiệu. Mỗi bước có thao tác, mã cần nhập, giải thích và kết quả để tự kiểm tra.

## 1 Mục tiêu và quy tắc thực hành

Sau bài này, sinh viên cần phân biệt được Widget, BuildContext, Scaffold, AppBar và body; dùng được Row, Column, Container, Padding, Expanded, Stack; bố trí màn hình không bị tràn khi nội dung dài.

Thực hiện đúng các quy tắc sau:

1. Nhập mã theo thứ tự các bước, không chép toàn bộ mã cuối ngay từ đầu.
2. Đọc rõ chỉ dẫn **tạo tệp**, **thay toàn bộ**, **thêm cuối tệp** hoặc **thay một thuộc tính**. Không giữ lại đoạn cũ khi được yêu cầu thay.
3. Lưu tệp bằng `Ctrl + S` sau mỗi bước. Chỉ chuyển bước khi màn hình đúng với phần kết quả.
4. Code Dart dùng dấu nháy thẳng `'` hoặc `"`; không dùng dấu nháy cong do Word tự thay thế. Tên thư mục và tệp viết đúng như hướng dẫn.
5. Khi xuất hiện lỗi, đọc lỗi đầu tiên trong terminal hoặc bảng Problems. Không sửa nhiều chỗ cùng lúc khi chưa hiểu nguyên nhân.

**Phạm vi:** Bài này dùng dữ liệu mẫu cố định. Nút cộng chỉ hiện thông báo, chưa thêm hoặc lưu công việc. Không cần cài thêm thư viện.

## 2 Chuẩn bị môi trường

**Thao tác**

1. Mở Visual Studio Code.
2. Kiểm tra đã cài extension **Flutter** và **Dart**. Có thể mở Extensions bằng `Ctrl + Shift + X` và tìm theo tên.
3. Chọn **Terminal → New Terminal**. Các lệnh dưới đây dành cho terminal PowerShell trên Windows.
4. Nhập lần lượt:

```powershell
flutter --version
dart --version
flutter doctor
```

**Kết quả cần đạt:** terminal nhận được lệnh Flutter và Dart. Với cách chạy web trong bài, cần có Chrome và Flutter hỗ trợ web. Cảnh báo về Android hoặc Visual Studio không nhất thiết ngăn chạy Chrome; đọc mục thiết bị và web trong kết quả doctor. Nếu lệnh không được nhận, báo giảng viên kiểm tra Flutter SDK và PATH trước khi tiếp tục.

Các ví dụ cuối bài được kiểm tra với Flutter 3.47.4 và Dart 3.13.3. Nếu dùng SDK cũ và không nhận `withValues` hoặc `CardThemeData`, xem bảng xử lý lỗi ở cuối tài liệu.

## 3 Tạo project mới và chạy thử

**Thao tác**

1. Trong PowerShell, tạo thư mục thực hành riêng. Dùng thư mục này để không ghi đè project mẫu của giảng viên:

```powershell
New-Item -ItemType Directory -Path 'D:\FlutterPractice' -Force
Set-Location -LiteralPath 'D:\FlutterPractice'
flutter create --platforms=android,web --project-name sonatasks_bai02 sonatasks_bai02
Set-Location -LiteralPath 'D:\FlutterPractice\sonatasks_bai02'
flutter pub get
flutter devices
```

Nếu máy không có ổ D, đổi `D:\FlutterPractice` thành một thư mục có quyền ghi, ví dụ `C:\FlutterPractice`, trong tất cả các lệnh. Nếu thư mục project đã có từ lần thực hành trước, mở project đó hoặc chọn thư mục mới; không xóa project cũ.

2. Chọn **File → Open Folder**, mở `D:\FlutterPractice\sonatasks_bai02`. Chọn thư mục có tệp `pubspec.yaml`, không chọn riêng thư mục `lib`.
3. Terminal mới trong VS Code cần đang ở thư mục project. Chạy:

```powershell
flutter run -d chrome
```

**Kết quả cần đạt:** Chrome mở ứng dụng đếm số mặc định của Flutter. Nhấn dấu cộng, số đếm tăng. Đây là kiểm tra môi trường trước khi sửa mã.

**Cách cập nhật khi thực hành:** giữ terminal đang chạy app. Sau khi lưu mã, đặt con trỏ vào terminal này rồi nhấn `r` để hot reload; nhấn `R` để hot restart khi thay đổi cấu trúc ứng dụng hoặc reload chưa cập nhật. Nhấn `q` để dừng. Nếu chạy lại lệnh Flutter, dùng terminal thứ hai hoặc dừng lần chạy trước.

## 4 Tạo cấu trúc tệp

Trong Explorer bên trái của VS Code:

1. Nhấp phải thư mục `lib`, chọn **New Folder**, nhập `screens`.
2. Nhấp phải `screens`, chọn **New File**, nhập `home_screen.dart`.
3. Giữ tệp `lib/main.dart` có sẵn. Chưa tạo tệp giới thiệu; tệp đó thuộc phần mở rộng.

Cấu trúc hiện tại:

```text
sonatasks_bai02/
  lib/
    main.dart
    screens/
      home_screen.dart
  test/
    widget_test.dart
  pubspec.yaml
```

Tệp `test/widget_test.dart` được Flutter tạo cho ứng dụng đếm mặc định. Sau khi đổi ứng dụng, test cũ sẽ không còn phù hợp. Ở bước kiểm tra cuối, sinh viên sẽ thay test này bằng test cho SonaTasks.

## 5 Nhập khung màn hình Home

**Thao tác:** mở `lib/screens/home_screen.dart` và nhập toàn bộ mã sau:

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SonaTasks'),
      ),
      body: const Center(
        child: Text('Màn hình Home của SonaTasks'),
      ),
    );
  }
}
```

**Giải thích**

- `import` đưa các widget Material vào tệp.
- `StatelessWidget` dùng cho giao diện không có trạng thái thay đổi bên trong. Bài này đang hiển thị dữ liệu cố định.
- `build()` trả về cây widget mô tả giao diện.
- `BuildContext` xác định vị trí widget trong cây; các bước sau dùng nó để tìm theme và hiển thị thông báo.
- `Scaffold` là khung màn hình; `appBar` là thanh trên cùng; `body` là nội dung bên dưới.
- `Center` đặt chữ ở giữa vùng body; `Text` hiển thị chữ.

**Lưu ý:** màn hình này chưa xuất hiện trong app cho tới khi nối với `main.dart` ở bước tiếp theo.

## 6 Nối HomeScreen với ứng dụng

**Thao tác:** mở `lib/main.dart`, chọn tất cả bằng `Ctrl + A`, **thay toàn bộ nội dung** bằng:

```dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SonaTasksApp());
}

class SonaTasksApp extends StatelessWidget {
  const SonaTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SonaTasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF315ACB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      ),
      home: const HomeScreen(),
    );
  }
}
```

Lưu cả hai tệp, nhấn `R` trong terminal đang chạy Flutter.

**Kết quả cần đạt:** có thanh tiêu đề “SonaTasks” và chữ “Màn hình Home của SonaTasks” ở giữa. Màn hình đếm số cũ đã được thay.

**Giải thích:** `main()` là điểm bắt đầu; `runApp()` chạy widget gốc. `MaterialApp` thiết lập ứng dụng Material, theme và trang đầu tiên. `home: const HomeScreen()` chọn màn hình vừa tạo. Mã màu `0xFF315ACB` gồm độ đục `FF` và màu RGB `315ACB`.

**Tự thao tác:** đổi chữ trong `body` thành họ tên của mình, lưu và reload để kiểm tra, sau đó đổi về chữ ban đầu.

## 7 Thêm dữ liệu công việc mẫu

**Thao tác:** quay lại `lib/screens/home_screen.dart`. Giữ dòng import. **Thêm đoạn sau ngay dưới dòng import và trước `class HomeScreen`**:

```dart
class Task {
  const Task(this.title, this.description, {this.isDone = false});

  final String title;
  final String description;
  final bool isDone;
}

const sampleTasks = <Task>[
  Task(
    'Ôn tập Dart cơ bản',
    'Biến, kiểu dữ liệu và hàm',
    isDone: true,
  ),
  Task(
    'Dựng layout màn hình Home',
    'Thực hành Row, Column và Expanded',
  ),
  Task(
    'Hoàn thành bài tập Flutter',
    'Kiểm tra giao diện trên điện thoại',
  ),
  Task(
    'Đọc tài liệu về Widget',
    'Tìm hiểu Scaffold và BuildContext',
    isDone: true,
  ),
  Task(
    'Chuẩn bị bài học tiếp theo',
    'Widget, Form và quản lý trạng thái',
  ),
];
```

**Kết quả cần đạt:** không có lỗi cú pháp; giao diện chưa thay đổi vì dữ liệu chưa được đưa vào widget.

**Giải thích:** `Task` mô tả một công việc. `title` và `description` là chuỗi; `isDone` là giá trị đúng hoặc sai, mặc định `false`. `sampleTasks` có 5 công việc, hai công việc đánh dấu `true`. `final` ngăn gán lại thuộc tính; `const` cho phép tạo dữ liệu hằng trong ví dụ này.

## 8 Tạo widget thẻ thống kê

**Thao tác:** trong cùng tệp `home_screen.dart`, cuộn xuống cuối. **Thêm toàn bộ lớp sau sau dấu `}` đóng lớp HomeScreen**, không đặt bên trong `build()` hoặc bên trong HomeScreen:

```dart
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
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
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
```

**Giải thích:** `Container` tạo vùng nền có viền, bo góc và padding. `Row` xếp các phần tử theo chiều ngang. `Expanded` cho phần chữ nhận chiều rộng còn lại giữa biểu tượng và số, giúp chữ xuống dòng khi thiếu chỗ. `SizedBox(width: ...)` tạo khoảng cách ngang. `'$value'` chuyển số thành chuỗi hiển thị. `Theme.of(context)` lấy kiểu chữ từ theme của ứng dụng.

**Kết quả cần đạt:** không có lỗi; thẻ chưa xuất hiện vì chưa được gọi trong HomeScreen.

## 9 Đưa phần thống kê lên Home

**Thao tác:** tìm `class HomeScreen`. **Chỉ thay toàn bộ lớp HomeScreen cũ bằng lớp dưới đây**. Giữ nguyên dữ liệu Task và lớp StatCard bên ngoài.

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final done = sampleTasks.where((task) => task.isDone).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SonaTasks'),
      ),
      body: SafeArea(
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
            StatCard(
              label: 'Tổng công việc',
              value: sampleTasks.length,
              icon: Icons.assignment_outlined,
              color: const Color(0xFF315ACB),
            ),
            const SizedBox(height: 10),
            StatCard(
              label: 'Đã xong',
              value: done,
              icon: Icons.check_circle_outline,
              color: const Color(0xFF16815D),
            ),
            const SizedBox(height: 10),
            StatCard(
              label: 'Chưa xong',
              value: sampleTasks.length - done,
              icon: Icons.schedule,
              color: const Color(0xFFAA6514),
            ),
          ],
        ),
      ),
    );
  }
}
```

Lưu, reload và quan sát.

**Kết quả cần đạt:** phía dưới phần giới thiệu có ba thẻ xếp dọc: Tổng công việc **5**, Đã xong **2**, Chưa xong **3**.

**Giải thích:** `where()` lọc các công việc đã xong; `.length` đếm số phần tử. Số chưa xong bằng tổng trừ số đã xong. `ListView` cho toàn bộ nội dung cuộn khi vượt chiều cao. `SafeArea` giúp tránh vùng hệ thống trên thiết bị. `EdgeInsets.fromLTRB` lần lượt là trái, trên, phải, dưới; khoảng dưới 100 sẽ tạo chỗ cuộn cho nút nổi ở bước sau.

**Tự thao tác:** tạm đổi `isDone` của một công việc chưa xong thành `true`. Nhấn `R`, kiểm tra số thành 5, 3, 2. Sau đó đổi lại và restart để quay về dữ liệu mẫu.

## 10 Tạo widget thẻ công việc

**Thao tác:** thêm toàn bộ lớp sau **ở cuối `home_screen.dart`, sau lớp StatCard**:

```dart
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
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
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
```

**Giải thích:** `Padding` tạo khoảng trống giữa nội dung và mép thẻ. `Row` đặt biểu tượng bên trái, phần chữ bên phải. `Column` xếp tên, mô tả, trạng thái theo chiều dọc. `Stack` xếp chồng widget; `Positioned` đưa dấu hoàn thành vào góc dưới bên phải biểu tượng. Toán tử `điều_kiện ? giá_trị_đúng : giá_trị_sai` chọn màu và nhãn trạng thái. Chỉ vùng biểu tượng có kích thước cố định; phần chữ tự tăng chiều cao để không bị cắt.

**Kết quả cần đạt:** mã không lỗi; thẻ chưa hiển thị vì chưa đưa vào danh sách.

## 11 Đưa danh sách công việc lên Home

**Thao tác:** trong HomeScreen, tìm **StatCard cuối cùng có nhãn `Chưa xong`**. Ngay sau dấu `),` đóng thẻ đó, **trước dấu `],` kết thúc `children` của ListView**, thêm:

```dart
            const SizedBox(height: 24),
            Text(
              'Danh sách công việc',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text('${sampleTasks.length} công việc mẫu • $done đã hoàn thành'),
            const SizedBox(height: 12),
            for (final task in sampleTasks) TaskCard(task: task),
```

Đoạn này thuộc danh sách `children: [...]`, không thuộc tham số của StatCard. Không thêm một `ListView` khác.

**Kết quả cần đạt:** có tiêu đề “Danh sách công việc”, dòng “5 công việc mẫu • 2 đã hoàn thành” và 5 thẻ. Cuộn xuống để xem công việc cuối “Chuẩn bị bài học tiếp theo”. Hai công việc đã xong có màu xanh lá và dấu tích.

**Giải thích:** collection `for` tạo một TaskCard cho mỗi phần tử dữ liệu. ListView ngoài cùng cuộn cả thống kê và danh sách. Với lượng dữ liệu lớn ở bài sau, có thể dùng danh sách tạo phần tử theo nhu cầu.

## 12 Thêm nút nổi

**Thao tác:** trong `return Scaffold(...)` của HomeScreen, thêm thuộc tính dưới đây **ngay sau thuộc tính `body: SafeArea(...)` và trước dấu `);` đóng Scaffold**. Nút nổi là thuộc tính cùng cấp với `appBar` và `body`, không đặt trong `children` của ListView.

```dart
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
```

Lưu và reload. Nhấn nút cộng.

**Kết quả cần đạt:** có nút cộng ở góc dưới bên phải; nhấn nút hiện thông báo. Cuộn danh sách tới cuối, bảo đảm có thể đưa thẻ cuối lên khỏi vùng nút nổi.

**Giải thích:** `onPressed` chứa mã chạy khi người dùng nhấn nút. `ScaffoldMessenger.of(context)` tìm thành phần quản lý thông báo; `showSnackBar` hiển thị thông báo. `hideCurrentSnackBar` tránh xếp hàng nhiều thông báo khi nhấn liên tiếp.

**Đến đây đã hoàn thành phần bắt buộc.** Sinh viên kiểm tra giao diện trước khi làm mở rộng.

## 13 Chỉnh giao diện cho dễ đọc

**Thao tác:** mở `main.dart`. Trong `theme: ThemeData(...)`, **thêm hai thuộc tính sau ngay sau `scaffoldBackgroundColor`**:

```dart
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFFF7F8FC),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
        ),
```

**Kết quả cần đạt:** tiêu đề canh trái, nền AppBar cùng màu nền màn hình, các thẻ công việc nền trắng. Khoảng đệm hai bên nội dung bằng nhau. Không có đoạn chữ bị cắt.

**Tự thao tác:** đổi tạm tên một công việc thành “Hoàn thành bài thực hành layout Flutter và kiểm tra giao diện trên màn hình điện thoại nhỏ”. Kiểm tra tên xuống dòng và thẻ tăng chiều cao, sau đó khôi phục tên mẫu.

## 14 Mở rộng bố cục ngang cho thống kê

**Thao tác:** trong `children` của ListView, tìm cụm từ **StatCard đầu tiên nhãn `Tổng công việc`** đến hết **StatCard thứ ba nhãn `Chưa xong`**, bao gồm hai `SizedBox(height: 10)` giữa các thẻ. **Thay đúng cụm này bằng đoạn sau**. Giữ phần giới thiệu phía trước và tiêu đề danh sách phía sau.

```dart
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

                final canUseRow = constraints.maxWidth >= 600 &&
                    MediaQuery.textScalerOf(context).scale(14) <= 21;

                if (canUseRow) {
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
```

**Giải thích:** `LayoutBuilder` cung cấp ràng buộc chiều rộng của vùng nội dung. Khi vùng này rộng ít nhất 600 logical pixel và chữ chưa quá lớn, dùng Row và Expanded để chia đều ba thẻ. Nếu vùng hẹp hoặc chữ lớn, dùng Column. Không chỉ kiểm tra thiết bị đang xoay ngang: điều quyết định là không gian thật sự còn lại cho nội dung.

`...[...]` trải các phần tử của một danh sách con vào danh sách `children`. Ở đây, mỗi lần lặp thêm khoảng cách nếu cần rồi thêm một thẻ.

**Kết quả cần đạt:** màn hình hẹp có ba thẻ dọc; mở rộng cửa sổ Chrome hoặc xoay ngang điện thoại đủ rộng thì có ba thẻ cùng hàng. Nếu cỡ chữ lớn, thẻ có thể trở lại xếp dọc để dễ đọc.

## 15 Mở rộng màn hình giới thiệu

### 15 1 Tạo tệp giới thiệu

Nhấp phải `lib/screens`, chọn **New File**, đặt tên `about_screen.dart`. Nhập toàn bộ:

```dart
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
            const Icon(
              Icons.task_alt,
              size: 72,
              color: Color(0xFF315ACB),
            ),
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
```

### 15 2 Nối nút thông tin với màn hình mới

Mở `home_screen.dart`. **Thêm dòng import sau dưới import Material ở đầu tệp**:

```dart
import 'about_screen.dart';
```

Trong HomeScreen, **thay toàn bộ thuộc tính `appBar` cũ bằng**:

```dart
      appBar: AppBar(
        title: const Text('SonaTasks'),
        actions: [
          IconButton(
            tooltip: 'Giới thiệu ứng dụng',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AboutScreen(),
              ),
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
```

**Kết quả cần đạt:** AppBar có nút thông tin bên phải; nhấn mở trang giới thiệu; nhấn “Về trang chủ” quay lại Home. Xoay ngang vẫn cuộn được nội dung giới thiệu.

**Giải thích:** `Navigator.push` đưa màn hình mới vào ngăn xếp điều hướng; `MaterialPageRoute` tạo tuyến màn hình. `Navigator.pop` đóng màn hình hiện tại và quay về màn hình trước. Đây là phần mở rộng; chưa cần học sâu về điều hướng ở bài layout.

## 16 Kiểm tra bằng thao tác trên giao diện

Với Chrome, mở DevTools bằng `F12` hoặc `Ctrl + Shift + I`, bật **Toggle device toolbar** bằng `Ctrl + Shift + M`, chọn chế độ **Responsive**, nhập kích thước rồi quan sát app. Khi kiểm tra trên điện thoại thật, xoay thiết bị và thay đổi cỡ chữ trong cài đặt hệ thống.

| Lần kiểm tra | Thao tác | Kết quả đạt |
| --- | --- | --- |
| 1 | Đặt vùng xem 320 × 568 | Chữ không tràn ngang, thống kê xếp dọc |
| 2 | Cuộn tới cuối danh sách | Thấy công việc thứ năm, có thể cuộn khỏi nút cộng |
| 3 | Đặt vùng xem 390 × 844 | Bố cục điện thoại rõ ràng, khoảng đệm đều |
| 4 | Đặt vùng xem 844 × 390 | Nếu đã làm mở rộng, thống kê cùng hàng và nội dung cuộn được |
| 5 | Nhấn dấu cộng nhiều lần | Có thông báo, ứng dụng vẫn hoạt động |
| 6 | Mở giới thiệu rồi quay lại | Trở về đúng màn hình Home |
| 7 | Tăng cỡ chữ hệ thống trên điện thoại | Nội dung xuống dòng, cuộn được, không bị cắt |
| 8 | Đổi một tiêu đề thành chuỗi dài | Thẻ tăng chiều cao, chữ không tràn sang phải |

Không dùng zoom trình duyệt để khẳng định đã kiểm tra cỡ chữ hệ thống. Phần kiểm thử dưới đây kiểm tra riêng cơ chế tăng cỡ chữ Flutter.

## 17 Thay test mẫu và kiểm tra mã

**Thao tác:** mở `test/widget_test.dart`, **thay toàn bộ test của ứng dụng đếm cũ** bằng:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonatasks_bai02/main.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('Home không tràn ở $size với chữ $scale', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = scale;

        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(
          tester.platformDispatcher.clearTextScaleFactorTestValue,
        );

        await tester.pumpWidget(const SonaTasksApp());
        await tester.pumpAndSettle();

        expect(find.text('SonaTasks'), findsOneWidget);
        expect(find.text('Tổng công việc'), findsOneWidget);
        expect(tester.takeException(), isNull);

        for (final value in ['5', '2', '3']) {
          await tester.scrollUntilVisible(
            find.text(value),
            100,
            scrollable: find.byType(Scrollable),
          );
          await tester.pumpAndSettle();
          expect(find.text(value), findsOneWidget);
          expect(tester.takeException(), isNull);
        }

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

  testWidgets('Nút thêm hiển thị thông báo', (tester) async {
    await tester.pumpWidget(const SonaTasksApp());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chức năng thêm công việc'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
```

Nếu tạo project bằng tên khác, sửa `package:sonatasks_bai02/main.dart` theo trường `name` trong `pubspec.yaml`. Không thay bằng đường dẫn ổ đĩa. Trước khi chạy test, khôi phục đúng 5 công việc mẫu và các trạng thái ở bước 7.

Mở terminal thứ hai trong VS Code bằng **Terminal → New Terminal**, chạy từng lệnh tại thư mục project:

```powershell
dart format lib test
flutter analyze
flutter test
flutter build web
```

**Kết quả cần đạt:** format chạy thành công; analyze không có lỗi; test báo **All tests passed** với 7 test; build web thành công. Kiểm thử này chạy được với cả phần bắt buộc và phần mở rộng. Ảnh chức năng chính phải chụp từ app đang chạy theo bước 18.

**Giải thích:** `pumpWidget` dựng ứng dụng trong môi trường test; `pumpAndSettle` chờ giao diện ổn định; `find` tìm widget; `expect` đối chiếu kết quả; `takeException` kiểm tra Flutter có báo ngoại lệ hay không. `addTearDown` trả các thiết lập màn hình về trạng thái ban đầu sau từng test.

## 18 Chụp ảnh và chuẩn bị sản phẩm nộp

### 18 1 Chụp ảnh chức năng chính

1. Chạy app, đưa về màn hình Home.
2. Trên Chrome, dùng vùng xem điện thoại, ví dụ 390 × 844. Chụp phần đầu để thấy tiêu đề, thống kê và danh sách; chụp thêm phần cuối nếu cần chứng minh đủ 5 công việc.
3. Trên Windows có thể dùng `Win + Shift + S` để chọn vùng chụp. Trên emulator dùng nút chụp màn hình của emulator; trên điện thoại dùng tổ hợp phím chụp của thiết bị.
4. Tạo thư mục `screenshots` trong project, lưu các ảnh `home_doc.png` và `home_cuoi_danh_sach.png`.
5. Nếu làm mở rộng, chụp thêm `home_ngang.png` và `gioi_thieu.png`.

Ảnh cần thể hiện giao diện đang chạy, đủ rõ để đọc, không có vạch báo tràn màu vàng đen.

### 18 2 Viết README từ 5 đến 10 dòng

Mở `README.md`, thay nội dung mặc định bằng mẫu 9 dòng sau và bổ sung họ tên hoặc mã sinh viên trong thông tin nộp bài của lớp:

```text
# SonaTasks Bài 02
Ứng dụng thực hành layout màn hình Home bằng Flutter.
Có AppBar, thống kê và danh sách 5 công việc giả lập.
Thống kê gồm 5 tổng công việc, 2 đã xong và 3 chưa xong.
Nút cộng hiển thị thông báo, chưa thêm hoặc lưu công việc.
Cách chạy: flutter pub get rồi flutter run -d chrome.
Kiểm tra: flutter analyze và flutter test.
Ảnh màn hình nằm trong thư mục screenshots.
Lỗi còn tồn tại: ghi rõ lỗi thực tế hoặc ghi không phát hiện trong các bước đã kiểm tra.
```

Nếu đã làm mở rộng, thêm dòng thứ 10: “Mở rộng: bố cục ngang cho thống kê và màn hình giới thiệu.” Không ghi đã làm nếu chưa hoàn thành.

### 18 3 Đóng gói

Đặt tên file nộp theo quy định của giảng viên, ví dụ `MSSV_HoTen_Bai02.zip`. Zip thư mục project có `lib`, `test`, `android`, `web`, `pubspec.yaml`, `pubspec.lock`, `README.md` và `screenshots`. Có thể bỏ `build` và `.dart_tool` vì Flutter tạo lại. Không chỉ nộp riêng `main.dart`.

## 19 Bảng tự đánh giá

- [ ] Project mở được và chạy được bằng lệnh ghi trong README.
- [ ] AppBar hiển thị đúng “SonaTasks”.
- [ ] Có ba khu vực: giới thiệu, thống kê, danh sách.
- [ ] Tổng công việc 5, đã xong 2, chưa xong 3.
- [ ] Có đủ 5 công việc giả lập và cuộn tới công việc cuối.
- [ ] Có FloatingActionButton và phản hồi khi nhấn.
- [ ] Dùng Row, Column, Container, Padding, Expanded và Stack.
- [ ] Màn hình nhỏ không bị tràn, chữ dài xuống dòng.
- [ ] Đã thay test mặc định và chạy kiểm tra thành công.
- [ ] Có README 5 đến 10 dòng và ảnh màn hình.
- [ ] Nếu làm mở rộng, có bố cục ngang và màn hình giới thiệu hoạt động.

## 20 Lỗi thường gặp và cách khắc phục

| Lỗi hoặc hiện tượng | Cách kiểm tra và sửa |
| --- | --- |
| `flutter` không được nhận | Kiểm tra Flutter SDK và PATH, mở lại terminal sau khi cấu hình |
| Không tìm thấy `pubspec.yaml` | Đưa terminal về thư mục gốc project bằng Set-Location |
| `Target of URI doesn't exist` | Kiểm tra tên tệp, đường dẫn import và đã lưu tệp hay chưa |
| `HomeScreen` hoặc `StatCard` chưa được định nghĩa | Kiểm tra đã nhập lớp tương ứng và lớp nằm ngoài các lớp khác |
| `MyApp` không tồn tại trong test | Chưa thay test đếm số mặc định bằng test của SonaTasks |
| Báo thiếu dấu hoặc unexpected token | Kiểm tra dấu phẩy giữa tham số và cặp ngoặc tròn, vuông, nhọn; xem lỗi đầu tiên |
| App vẫn là màn hình đếm | Kiểm tra main.dart đã thay toàn bộ, home trỏ tới HomeScreen, lưu và hot restart |
| Vạch vàng đen bên phải | Phần chữ trong Row cần Expanded; không đặt chiều rộng chữ lớn hơn vùng chứa |
| Tràn phía dưới | Nội dung dài cần ListView; không thay ListView bằng Column không cuộn |
| Lỗi chiều cao vô hạn của Expanded | Không đặt Expanded theo chiều dọc trực tiếp trong ListView; Expanded của bài nằm trong Row |
| `withValues` không được nhận | SDK cũ; dùng SDK của lớp. Nếu buộc giữ SDK cũ, thay bằng `withOpacity(0.08)` và `withOpacity(0.2)` tương ứng |
| `CardThemeData` không được nhận | SDK cũ; có thể bỏ riêng thuộc tính cardTheme ở bước 13 để tiếp tục, hoặc dùng SDK của lớp |
| Giá trị thống kê khác 5 2 3 | Kiểm tra số phần tử sampleTasks và đúng hai công việc isDone true |
| Nút cộng không tạo công việc | Đây là hành vi dự kiến của bài layout; hiện tại chỉ yêu cầu nút và thông báo |
| Test lỗi sau khi đổi dữ liệu mẫu | Khôi phục dữ liệu ở bước 7 trước khi chạy test, hoặc sửa kỳ vọng nếu đã mở rộng dữ liệu |

## 21 Câu hỏi cuối buổi

Sinh viên trả lời bằng lời của mình trước khi xem gợi ý:

1. Vai trò của MaterialApp và Scaffold khác nhau thế nào?
2. Row xếp widget theo hướng nào? Column xếp theo hướng nào?
3. Vì sao phần chữ trong TaskCard cần Expanded?
4. Vì sao dùng ListView cho body thay vì chỉ dùng Column?
5. Stack và Positioned được sử dụng ở đâu trong bài?
6. Chức năng quan trọng nhất của Bài 02 là gì?
7. Hai nguyên nhân thường gây tràn màn hình là gì?
8. Nếu sau này có form thêm công việc, tiêu đề rỗng cần xử lý thế nào?

**Gợi ý đáp án để tự đối chiếu**

1. MaterialApp thiết lập ứng dụng, theme và điều hướng; Scaffold tạo khung của một màn hình với appBar, body, nút nổi.
2. Row theo chiều ngang; Column theo chiều dọc.
3. Để chữ có chiều rộng hữu hạn trong phần không gian còn lại và xuống dòng đúng cách.
4. ListView cuộn được khi tổng nội dung vượt chiều cao màn hình.
5. Xếp dấu hoàn thành lên góc biểu tượng của TaskCard.
6. Xây dựng bố cục màn hình Home rõ ràng, dùng đúng các widget layout và hiển thị tốt trên điện thoại.
7. Chữ dài trong Row thiếu giới hạn chiều rộng; nội dung dài trong Column không có vùng cuộn.
8. Trim khoảng trắng, báo lỗi tại trường nhập và không lưu khi tiêu đề rỗng. Bài này chưa có form nên chưa triển khai kiểm tra nhập liệu.

## 22 Phân bổ thời gian thực hành

| Phần | Thời gian gợi ý |
| --- | --- |
| Chuẩn bị tạo project và khung Home từ bước 2 đến 6 | 35 phút |
| Dữ liệu và thống kê từ bước 7 đến 9 | 45 phút |
| Thẻ công việc danh sách và nút nổi từ bước 10 đến 12 | 60 phút |
| Chỉnh giao diện và mở rộng từ bước 13 đến 15 | 45 phút |
| Kiểm tra chụp ảnh README và nộp từ bước 16 đến 21 | 55 phút |

Sinh viên cần hỗ trợ ưu tiên hoàn thành bước 12 rồi kiểm tra, chụp ảnh và nộp phần bắt buộc. Sinh viên hoàn thành sớm làm bước 13 đến 15 và giải thích điều kiện chuyển bố cục thống kê.

Tài liệu tham khảo chính thức: [Layouts in Flutter](https://docs.flutter.dev/ui/layout), [Hot reload](https://docs.flutter.dev/tools/hot-reload) và [Testing Flutter apps](https://docs.flutter.dev/testing/overview).
