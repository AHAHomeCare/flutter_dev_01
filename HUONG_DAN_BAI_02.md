# Hướng dẫn thực hiện Bài 02 Layout trong Flutter

Bài thực hành xây dựng màn hình Home của SonaTasks bằng các widget bố cục. Kết quả gồm thống kê 5 công việc, danh sách giả lập, nút thêm, bố cục thích ứng và màn hình giới thiệu. Dữ liệu chưa được lưu; mục tiêu của bài là hiểu cách ghép widget và tránh tràn màn hình.

## 1 Chuẩn bị và chạy project

Mở thư mục `D:\Project\801 Sonadezi\Lap trinh mobile\SourceCode\Bai02` bằng VS Code hoặc Android Studio. Trong terminal PowerShell chạy:

```powershell
Set-Location -LiteralPath 'D:\Project\801 Sonadezi\Lap trinh mobile\SourceCode\Bai02'
flutter pub get
flutter devices
flutter run -d chrome
```

Để chạy trên điện thoại Android, bật USB debugging, kết nối thiết bị hoặc mở Android Emulator rồi chạy `flutter run -d <device-id>` với ID lấy từ `flutter devices`. Nếu môi trường Android chưa sẵn sàng, chạy `flutter doctor` để xem thành phần cần bổ sung. Project cũng có cấu trúc iOS nhưng việc biên dịch iOS cần macOS và Xcode.

## 2 Hiểu cấu trúc mã nguồn

| Tệp | Vai trò |
| --- | --- |
| `lib/main.dart` | Điểm vào, MaterialApp, chủ đề màu và HomeScreen |
| `lib/screens/home_screen.dart` | Dữ liệu mẫu, HomeScreen, StatCard và TaskCard |
| `lib/screens/about_screen.dart` | Màn hình giới thiệu thuộc phần mở rộng |
| `test/widget_test.dart` | Kiểm tra bố cục, điều hướng, nút thêm và xuất ảnh |
| `screenshots` | Ảnh dựng trực tiếp từ widget Flutter trong kiểm thử |

## 3 Tạo khung ứng dụng

`main()` gọi `runApp(const SonaTasksApp())`. `SonaTasksApp` trả về `MaterialApp`, thiết lập Material 3 và chọn `HomeScreen` làm trang đầu tiên.

Widget là thành phần mô tả giao diện hoặc bố cục. `BuildContext` xác định vị trí của widget trong cây giao diện, cho phép tìm theme, Navigator và ScaffoldMessenger ở phía trên. `Scaffold` cung cấp khung màn hình; `AppBar` là thanh tiêu đề, `body` là nội dung và `floatingActionButton` là nút nổi.

```text
MaterialApp
  HomeScreen
    Scaffold
      AppBar tiêu đề SonaTasks
      SafeArea
        ListView
          Phần chào và giới thiệu
          LayoutBuilder chứa các StatCard
          Tiêu đề danh sách và các TaskCard
      FloatingActionButton
```

`SafeArea` tránh vùng hệ thống như tai thỏ. Padding của ListView là 16 ở hai bên và 100 phía dưới để có thể cuộn công việc cuối lên khỏi nút nổi.

## 4 Tạo dữ liệu giả lập

Lớp `Task` có ba thuộc tính: `title`, `description` và `isDone`. Danh sách `sampleTasks` chứa 5 phần tử, trong đó 2 phần tử có `isDone: true`.

```dart
final done = sampleTasks.where((task) => task.isDone).length;
final total = sampleTasks.length;
final pending = total - done;
```

Các số trên thẻ thống kê và dòng phụ dưới tiêu đề danh sách được tính từ dữ liệu. Khi thay đổi `sampleTasks`, các giá trị sẽ cập nhật trong lần dựng giao diện tiếp theo. Bài 02 không cần nhập liệu, API hoặc cơ sở dữ liệu nên dùng `StatelessWidget` là đủ.

## 5 Dựng phần thống kê

`StatCard` dùng `Container` tạo nền, bo góc, viền và khoảng đệm. Bên trong là `Row` gồm biểu tượng, tên thống kê và số lượng. `Expanded` bao tên thống kê để phần chữ nhận không gian còn lại và xuống dòng khi cần.

`LayoutBuilder` đọc chiều rộng thực tế của khu vực thống kê. Khi rộng từ 600 logical pixel và cỡ chữ không quá lớn, ba thẻ được đặt trong `Row`, mỗi thẻ nằm trong một `Expanded`. Trên màn hình hẹp hoặc cỡ chữ lớn, dùng `Column` để xếp các thẻ dọc. Đây là phần mở rộng hiển thị ngang của đề.

## 6 Dựng danh sách công việc

Mỗi `TaskCard` là `Card` chứa `Padding` và `Row`. Biểu tượng nằm bên trái; phần tên, mô tả và trạng thái nằm trong `Expanded` chứa `Column`. `crossAxisAlignment: CrossAxisAlignment.start` giúp các dòng chữ canh trái và nội dung canh trên.

`Stack` đặt dấu hoàn thành lên góc biểu tượng. Các `SizedBox` tạo khoảng cách 4, 8, 12 hoặc 24 logical pixel theo từng khu vực. Chữ dài được phép xuống dòng, không đặt chiều cao cố định cho thẻ.

Danh sách giả lập được thêm vào ListView bằng `for (final task in sampleTasks) TaskCard(task: task)`. Với dữ liệu lớn ở bài sau, có thể chuyển sang `ListView.builder` để tạo phần tử theo nhu cầu.

## 7 Thêm nút nổi và màn hình giới thiệu

`FloatingActionButton` dùng biểu tượng dấu cộng và tooltip “Thêm công việc”. Khi nhấn, `ScaffoldMessenger` hiện SnackBar giải thích chức năng thêm sẽ thực hiện ở bài sau. Nút chưa tạo công việc mới.

Nút thông tin trên AppBar mở `AboutScreen` bằng `Navigator.push` và `MaterialPageRoute`. Nút “Về trang chủ” gọi `Navigator.pop`. Trang giới thiệu dùng ListView để nội dung cuộn được khi xoay ngang.

## 8 Kiểm tra và lấy ảnh

```powershell
dart format lib test
flutter analyze
flutter test
flutter build web
```

Kiểm thử bố cục dùng ba kích thước 320 × 568, 390 × 844 và 844 × 390, mỗi kích thước chạy với hệ số chữ 1 và 2. Kiểm thử cuộn tới công việc cuối và kiểm tra Flutter không báo ngoại lệ. Kiểm thử tương tác kiểm tra thông báo nút thêm, mở trang giới thiệu và quay lại.

Kiểm thử cuối xuất `screenshots/home_doc.png` ở 390 × 1100 và `screenshots/home_ngang.png` ở 844 × 500 bằng RepaintBoundary. Đây là ảnh render của Flutter trong môi trường kiểm thử, không phải ảnh chụp từ thiết bị vật lý. Muốn ảnh thiết bị để nộp, chạy app trên điện thoại hoặc emulator rồi chụp màn hình bằng công cụ của thiết bị. Ảnh kiểm thử có thể dùng để đối chiếu bố cục.

## 9 Đối chiếu yêu cầu nghiệm thu

| Yêu cầu của đề | Cách thực hiện |
| --- | --- |
| AppBar tiêu đề SonaTasks | `HomeScreen.appBar` |
| Tổng công việc đã xong chưa xong | Ba StatCard với giá trị 5, 2, 3 |
| Danh sách giả lập | Năm TaskCard trong ListView |
| Nút thêm dạng FloatingActionButton | Nút cộng ở góc dưới |
| Khoảng cách và chữ dễ đọc | Padding, SizedBox, theme chữ và thẻ tự tăng chiều cao |
| Ít nhất ba khu vực rõ ràng | Giới thiệu, thống kê, danh sách |
| Dùng các widget bố cục | Row, Column, Container, Padding, Expanded, Stack |
| Bố cục ngang mở rộng | LayoutBuilder đổi cách sắp xếp thống kê |
| Giới thiệu ứng dụng mở rộng | AboutScreen và nút thông tin |

## 10 Lỗi thường gặp và cách sửa

| Hiện tượng | Nguyên nhân thường gặp | Cách sửa |
| --- | --- | --- |
| Vạch vàng đen bên phải | Chữ dài trong Row không có giới hạn chiều rộng | Bọc phần chữ bằng Expanded |
| Tràn phía dưới | Dùng Column chứa nội dung dài và không cuộn | Dùng ListView hoặc bố trí vùng cuộn có ràng buộc chiều cao |
| Báo chiều cao vô hạn | Đặt Expanded theo chiều dọc trong vùng cuộn không giới hạn | Bỏ Expanded dọc hoặc cấp chiều cao hữu hạn cho vùng chứa |
| Thẻ bị cắt khi tăng cỡ chữ | Gán height cố định cho thẻ chứa nhiều chữ | Để thẻ tăng chiều cao theo nội dung |
| Công việc cuối bị nút nổi che | Không có khoảng trống cuối danh sách | Tăng padding dưới để có thể cuộn lên |
| Không mở được project | Mở nhầm thư mục không chứa pubspec.yaml | Mở trực tiếp thư mục Bai02 |

## 11 Trả lời câu hỏi kiểm tra nhanh

**Chức năng quan trọng nhất của bài này là gì?** Dựng layout màn hình Home có thống kê và danh sách công việc bằng các widget bố cục cơ bản, hiển thị rõ ràng trên điện thoại.

**Lỗi nào sinh viên thường gặp?** RenderFlex overflow do chữ dài trong Row hoặc nội dung vượt chiều cao của Column; lỗi constraint khi đặt Expanded trong vùng cuộn không giới hạn.

**Nếu dữ liệu nhập sai hoặc thiếu thì xử lý thế nào?** Bài này chưa có biểu mẫu. Khi bổ sung ở bài sau, cần trim tiêu đề, không chấp nhận tiêu đề rỗng, hiển thị lỗi ngay tại trường nhập và chỉ lưu khi hợp lệ. Mô tả có thể cho phép bỏ trống; không tạo dữ liệu giả để thay cho lỗi nhập.

## 12 Gợi ý thực hành trong 4 giờ

1. 30 phút: chạy project và tìm hiểu MaterialApp, Scaffold, AppBar, body.
2. 50 phút: tạo dữ liệu mẫu và dựng các thẻ thống kê.
3. 60 phút: dựng TaskCard, bố trí danh sách và thêm nút nổi.
4. 40 phút: chỉnh giao diện nhỏ, ngang và thêm màn hình giới thiệu.
5. 60 phút: kiểm tra, sửa lỗi tràn, chụp ảnh và chuẩn bị nộp.

Nộp project có mã nguồn, README và ảnh chức năng chính. Có thể bỏ thư mục build và .dart_tool khi đóng gói vì Flutter sẽ tạo lại chúng.

Tài liệu tham khảo: [Layouts in Flutter](https://docs.flutter.dev/ui/layout) giải thích cách bố trí Row, Column, Container, ListView và Stack.
