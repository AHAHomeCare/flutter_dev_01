# Hướng dẫn thực hành Bài 03 — SonaTasks

Bài 03 kế thừa giao diện, theme, dữ liệu mẫu và các thẻ công việc của Bài 02. Mục tiêu là tạo khung điều hướng Home – Task – About, biểu mẫu thêm công việc và quản lý trạng thái bằng `setState`.

## 1. Chuẩn bị project

1. Mở thư mục `flutter_dev_01` chứa `pubspec.yaml` bằng VS Code hoặc Android Studio.
2. Mở terminal tại thư mục đó và kiểm tra đang dùng nhánh Bài 03:

```powershell
git branch --show-current
git switch Bai_03
flutter doctor
flutter pub get
flutter devices
```

3. Khởi động Android Emulator hoặc kết nối điện thoại đã bật USB debugging.
4. Chạy ứng dụng bằng ID thiết bị lấy từ `flutter devices`:

```powershell
flutter run -d <device-id>
```

Thay `<device-id>` bằng ID thực tế, ví dụ `emulator-5554`. Có thể chạy web bằng `flutter run -d chrome` để kiểm tra nhanh giao diện.

## 2. Xác định phần kế thừa Bài 02

| Nội dung | Thay đổi ở Bài 03 |
| --- | --- |
| `SonaTasksApp` và theme | Giữ theme; đổi trang đầu thành `AppShell` |
| Home có thống kê và danh sách | Chuyển thống kê, danh sách sang `TaskScreen`; Home chỉ chào mừng |
| 5 công việc mẫu, 2 việc đã xong | Giữ dữ liệu mẫu; cho phép thêm việc và thay đổi `isDone` |
| `StatCard`, `TaskCard` | Giữ bố cục thích ứng; thêm Checkbox và thông tin ưu tiên |
| Nút thêm chỉ hiện thông báo | Thay bằng biểu mẫu nhập và lưu công việc thật trong RAM |
| About mở bằng Navigator | Chuyển sang tab About trong khung chung |

Không cần tạo project Flutter mới khi thực hành từ Bài 02. Khi đổi tên package thành `sonatasks_bai03` trong `pubspec.yaml`, cập nhật các import package trong tệp kiểm thử rồi chạy lại `flutter pub get`.

## 3. Tìm hiểu cấu trúc mã nguồn

| Tệp | Vai trò |
| --- | --- |
| `lib/main.dart` | Điểm vào, MaterialApp, theme và AppShell |
| `lib/screens/app_shell.dart` | Scaffold chung, AppBar, menu dưới và badge |
| `lib/screens/home_screen.dart` | Logo trường và lời chào |
| `lib/screens/task_screen.dart` | Model Task, dữ liệu mẫu, danh sách, thống kê và Checkbox |
| `lib/widgets/add_task_form.dart` | Biểu mẫu, controller, kiểm tra dữ liệu và callback thêm việc |
| `lib/screens/about_screen.dart` | Giới thiệu ứng dụng, môn học và phiên bản |
| `assets/images/sonadezi_logo.png` | Logo Sonadezi |
| `test/widget_test.dart` | 9 kiểm thử chức năng và bố cục |
| `integration_test/app_test.dart` | Kiểm thử luồng ứng dụng trên Android |
| `test_driver/integration_test.dart` | Lưu ảnh kiểm thử vào thư mục screenshots |

## 4. Tạo khung chung và điều hướng

1. Tạo `AppShell` dạng `StatefulWidget` trong `lib/screens/app_shell.dart`.
2. Khai báo `int currentIndex = 0` để chọn Home khi mở ứng dụng.
3. Tạo một `Scaffold` chung với AppBar, body và BottomNavigationBar.
4. AppBar có tiêu đề **SonaTasks**, biểu tượng thông báo và tài khoản bên phải.
5. Tạo ba mục menu **Home**, **Task**, **About**, mỗi mục có icon và nhãn.
6. Gán `currentIndex` cho menu. Trong `onTap`, gọi `_selectScreen` để cập nhật chỉ số bằng `setState`.
7. Dùng `IndexedStack` trong `SafeArea` để hiển thị màn hình đang chọn và giữ State của Task khi đổi tab.

```text
MaterialApp
  AppShell
    Scaffold
      AppBar: SonaTasks + thông báo + tài khoản
      SafeArea
        IndexedStack
          HomeScreen
          TaskScreen
          AboutScreen
      BottomNavigationBar: Home | Task | About
```

Các Screen con chỉ trả về nội dung; khung AppBar và menu đặt tại AppShell. `_selectScreen` cũng ẩn bàn phím và SnackBar khi đổi tab.

**Kiểm tra:** lần lượt chọn ba tab. Phần giữa thay đổi, AppBar và menu vẫn hiển thị, mục đang chọn được tô màu.

## 5. Tạo màn hình Home và khai báo logo

1. Đặt logo tại `assets/images/sonadezi_logo.png`.
2. Khai báo asset dưới mục `flutter` của `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/sonadezi_logo.png
```

3. Chạy `flutter pub get`, sau đó khởi động lại ứng dụng nếu vừa bổ sung asset.
4. Trong `HomeScreen`, dùng `Image.asset` hiển thị logo.
5. Thêm hai dòng chữ, căn giữa:

   - `TRƯỜNG CAO ĐẲNG CÔNG NGHỆ VÀ QUẢN TRỊ SONADEZI`
   - `Chào mừng đến với ứng dụng SonaTasks`

6. Dùng `LayoutBuilder`, `SingleChildScrollView` và `ConstrainedBox` để nội dung vừa được căn giữa vừa cuộn được trên màn hình thấp.

**Kiểm tra:** Home có logo, tên trường và lời chào; biểu mẫu và danh sách công việc nằm ở tab Task.

## 6. Tạo model và dữ liệu Task

1. Trong `task_screen.dart`, tạo lớp `Task` có `title`, `description`, `isDone` và `priority`.
2. Giữ `title`, `description`, `priority` là `final`; cho phép sửa `isDone` khi chọn Checkbox.
3. Dùng `createSampleTasks()` tạo một danh sách mới gồm 5 việc kế thừa Bài 02, trong đó 2 việc hoàn thành.
4. Trong State của TaskScreen, khởi tạo:

```dart
final List<Task> _tasks = createSampleTasks();
bool _onlyPending = false;
```

5. Tính tổng, đã xong và chưa xong từ danh sách. Dùng lại `StatCard` và `LayoutBuilder`: màn hình rộng xếp ngang; màn hình hẹp xếp dọc.

**Kiểm tra:** ban đầu có 5 việc, 2 đã xong và 3 chưa xong.

## 7. Tạo AddTaskForm và controller

1. Tạo tệp `lib/widgets/add_task_form.dart` và widget `AddTaskForm` dạng StatefulWidget.
2. Khai báo hai `TextEditingController` cho tên và mô tả.
3. Tạo hai `TextField` với nhãn **Tên công việc** và **Mô tả**; mô tả có thể xuống dòng.
4. Thêm `ElevatedButton` có chữ **Lưu công việc**.
5. Khai báo callback `onAdd` nhận ba giá trị: tên, mô tả và ưu tiên.
6. Gắn `AddTaskForm(onAdd: _addTask)` vào đầu ListView của TaskScreen.
7. Trong `dispose()`, gọi `dispose()` cho cả hai controller trước `super.dispose()`.

Callback giúp form chuyển dữ liệu cho TaskScreen; TaskScreen là nơi sở hữu danh sách và thực hiện thêm việc.

## 8. Kiểm tra dữ liệu và lưu công việc

1. Khi nhấn lưu, đọc tên và mô tả qua controller, gọi `.trim()` để bỏ khoảng trắng ở đầu và cuối.
2. Nếu tên rỗng, hiện SnackBar **Vui lòng nhập tên công việc.** và `return`; không thêm phần tử.
3. Nếu hợp lệ, gọi `widget.onAdd(title, description, _priority)`.
4. Trong `_addTask` của TaskScreen, thêm Task trong `setState`:

```dart
void _addTask(String title, String description, String priority) {
  setState(() {
    _tasks.add(Task(title, description, priority: priority));
  });
  _notifyPendingCount();
}
```

5. Xóa cả hai ô bằng `.clear()`, đưa ưu tiên về **Bình thường**, ẩn bàn phím và hiện SnackBar **Đã lưu công việc.**

**Thực hành:** thử lưu tên rỗng và tên chỉ có khoảng trắng; cả hai đều bị chặn. Sau đó thêm hai công việc, ví dụ **Ôn tập Flutter** và **Nộp bài thực hành 03**. Tổng tăng từ 5 lên 7, chưa xong tăng từ 3 lên 5. Mô tả được phép bỏ trống.

## 9. Thêm Checkbox và cập nhật trạng thái

1. Trong TaskCard, thêm Checkbox với `value: task.isDone`.
2. Chuyển giá trị mới cho `_toggleTask` của TaskScreen.
3. Trong `setState`, gán `task.isDone = value ?? false`.
4. Gọi `_notifyPendingCount()` để cập nhật badge trên AppBar.
5. Với việc hoàn thành, hiển thị dấu hoàn thành, chữ gạch ngang và trạng thái **Đã xong**.

**Kiểm tra:** chọn một việc chưa xong. Tổng giữ nguyên, đã xong tăng 1 và chưa xong giảm 1. Bỏ chọn sẽ đảo lại các số này.

## 10. Tạo About và các chức năng mở rộng

1. Trong AboutScreen, hiển thị **SonaTasks**, **Môn Lập trình Mobile với Flutter** và **Phiên bản 1.0.0**.
2. Dùng ListView để nội dung cuộn được khi xoay ngang hoặc tăng cỡ chữ.
3. Trong AddTaskForm, dùng `DropdownButton<String>` chọn **Thấp**, **Bình thường**, **Cao**; lưu ưu tiên cùng Task và hiển thị trong TaskCard.
4. Trong AppShell, dùng Badge bao quanh icon chuông. Badge hiển thị số việc chưa hoàn thành, ẩn khi bằng 0.
5. Truyền callback `onPendingChanged` cho TaskScreen để đồng bộ số chưa xong về AppShell sau khi thêm việc hoặc đổi Checkbox.
6. Nhấn chuông để xem SnackBar số việc chưa hoàn thành.
7. Nhấn icon tài khoản để mở AlertDialog; nhấn **Đóng** để quay lại.
8. Dùng Switch **Chỉ hiện việc chưa hoàn thành** để lọc danh sách. Thẻ thống kê vẫn tính toàn bộ công việc.

## 11. Kiểm tra dữ liệu khi chuyển tab

1. Thêm hai công việc ở Task.
2. Chuyển sang About rồi Home.
3. Quay lại Task: các việc vừa thêm và trạng thái Checkbox vẫn còn nhờ IndexedStack giữ State.
4. Khởi động lại ứng dụng: danh sách trở về 5 việc mẫu.

Dữ liệu của bài này chỉ lưu trong RAM. Hot restart hoặc đóng và mở lại ứng dụng sẽ tạo lại dữ liệu mẫu; bài chưa dùng cơ sở dữ liệu hay API.

## 12. Chạy kiểm thử

Tại thư mục project, chạy:

```powershell
flutter analyze
flutter test
flutter build web
```

`test/widget_test.dart` gồm 9 kiểm thử: Home và khung chung; menu và About; tên rỗng; thêm hai việc và giữ dữ liệu qua tab; ưu tiên; Checkbox, badge và bộ lọc; chuông và tài khoản; màn hình nhỏ có bàn phím; danh sách mẫu độc lập.

Để kiểm thử luồng trên Android và xuất ảnh, khởi động thiết bị rồi chạy, thay ID nếu cần:

```powershell
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d emulator-5554
```

Kiểm thử tự động nhập liệu qua kênh test và xuất ảnh vùng giao diện Flutter bằng RepaintBoundary trong khi ứng dụng chạy trên Android; ảnh không bao gồm thanh hệ thống của thiết bị. Lệnh này cập nhật các ảnh trong `screenshots`.

## 13. Đối chiếu ảnh và chuẩn bị nộp

| Ảnh | Nội dung |
| --- | --- |
| [01_home.png](screenshots/01_home.png) | Logo, tên trường, lời chào và khung chung |
| [02_task_form.png](screenshots/02_task_form.png) | Biểu mẫu Task |
| [03_task_validation.png](screenshots/03_task_validation.png) | Thông báo khi tên rỗng |
| [04_about.png](screenshots/04_about.png) | Giới thiệu ứng dụng |
| [05_task_after_two_added.png](screenshots/05_task_after_two_added.png) | Danh sách sau khi thêm hai việc |
| [06_task_checkbox.png](screenshots/06_task_checkbox.png) | Checkbox và thống kê cập nhật |
| [07_profile.png](screenshots/07_profile.png) | Dialog tài khoản |

- [ ] AppBar và menu cố định, đủ ba tab Home – Task – About.
- [ ] Home có logo và đúng lời chào; About có tên ứng dụng, môn học, phiên bản.
- [ ] Tên rỗng bị chặn bằng SnackBar; tên hợp lệ được lưu và form được xóa.
- [ ] Thêm ít nhất hai việc; chuyển tab vẫn giữ dữ liệu.
- [ ] Checkbox cập nhật danh sách, thống kê và badge.
- [ ] Ứng dụng chạy được trên Android; README và ảnh minh chứng đầy đủ.

Hướng dẫn Word chi tiết nằm tại [docs/Bai_03_Huong_dan_Thu_Hanh.docx](docs/Bai_03_Huong_dan_Thu_Hanh.docx). Khi đóng gói project có thể bỏ `build` và `.dart_tool` vì Flutter tạo lại các thư mục này.

## 14. Lỗi thường gặp

| Hiện tượng | Cách xử lý |
| --- | --- |
| Không thấy thiết bị Android | Mở emulator hoặc bật USB debugging; chạy `flutter devices` và `flutter doctor` |
| Không tìm thấy logo | Kiểm tra đường dẫn, thụt lề assets trong YAML; chạy pub get và khởi động lại app |
| Không nhận import package | Kiểm tra tên `sonatasks_bai03` trong pubspec và import kiểm thử; chạy pub get |
| Đổi tab mất danh sách | Giữ TaskScreen trong IndexedStack thay vì tháo và tạo lại State khi đổi tab |
| Thêm việc nhưng giao diện không đổi | Thực hiện thay đổi danh sách trong setState của TaskScreen |
| Badge không cập nhật | Gọi callback onPendingChanged sau khi thêm việc hoặc thay đổi Checkbox |
| Chữ hoặc bàn phím gây tràn | Dùng vùng cuộn và Expanded cho phần chữ trong Row; tránh chiều cao cố định cho nội dung dài |
| Mất việc sau khi khởi động lại | Đây là hành vi của dữ liệu RAM trong phạm vi Bài 03 |
