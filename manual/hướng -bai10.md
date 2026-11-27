# Bài 10 Kết nối SonaTasks với REST API

Trong bài này, bạn kết nối màn hình Task của Flutter với ESAPAPI. Khi hoàn thành, bạn có thể tải danh sách, lọc theo trạng thái, tạo công việc và đánh dấu hoàn thành. Máy chủ lưu trạng thái công việc để dùng lại khi mở ứng dụng.

## 1. Chuẩn bị và chạy trên Android

Mở PowerShell tại thư mục `flutter_dev_01`. Chuyển sang nhánh `Bai_10` khi thư mục làm việc sạch. Mở Android Emulator trước khi chạy ứng dụng.

```powershell
git fetch origin
git switch Bai_10
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Nếu mã thiết bị khác, thay `emulator-5554` bằng mã trong `flutter devices`. Trên Android, Bài 10 mặc định gọi `https://sona.somee.com/api/v1`.

Nếu chưa có thiết bị, chạy `flutter emulators` để xem danh sách, rồi chạy `flutter emulators --launch <id>` với ID máy ảo. Chờ Android vào màn hình chính và chạy lại `flutter devices` trước khi chạy app.

## 2. Đọc hợp đồng API

Các đường dẫn sau được nối vào địa chỉ gốc của ESAPAPI. Mỗi phản hồi thành công của các thao tác này có HTTP 200, `result.status = 200` và dữ liệu trong `data`.

| Thao tác | Phương thức và đường dẫn | Dữ liệu gửi |
| --- | --- | --- |
| Tải tất cả | GET /SonaTask/GetAll | Không có |
| Lọc trạng thái | GET /SonaTask/GetTaskByStatus | Query: status=0 hoặc status=1 |
| Tạo công việc | POST /SonaTask/CreateTask | JSON gồm name, description |
| Đổi trạng thái | POST /SonaTask/UpdateStatusTask/{id} | JSON gồm status dạng số |

`status = 0` là chưa hoàn thành và `status = 1` là đã hoàn thành. Khi phân tích JSON, Flutter đổi giá trị này sang `bool` để hiển thị checkbox.

## 3. Triển khai từng bước trong Flutter

### Bước 1. Kiểm tra thư viện HTTP và địa chỉ máy chủ

Trong VS Code, mở `pubspec.yaml` và tìm `http: ^1.6.0` dưới `dependencies`. Nếu đang làm từ bản chưa có thư viện này, thêm đúng mục trên rồi chạy `flutter pub get`. Trong `lib/screens/task_screen.dart`, tìm `_apiBaseUrl`. Kiểm tra địa chỉ Android là Somee hoặc dùng biến `SONATASK_API_URL` khi cần thử với máy chủ khác.

### Bước 2. Ánh xạ JSON sang đối tượng công việc

Mở `lib/services/sona_task_api.dart` và tìm `SonaTask.fromJson`. Đọc `id`, `name`, gán chuỗi rỗng cho `description` nếu API trả null và chuyển `status` sang boolean bằng so sánh với số 1. Trong `_data`, kiểm tra HTTP 200, giải mã `response.bodyBytes` bằng UTF-8 rồi đọc `result.status` và `data`. Cách này giữ đúng tiếng Việt trong tên công việc.

```dart
description: json['description'] as String? ?? '',
isDone: (json['status'] as int) == 1,
```

### Bước 3. Nối tải danh sách và bộ lọc

Trong cùng file, tạo `getAll()` và `getTaskByStatus(bool isDone)` để gọi GET và chuyển từng phần tử `data` thành `SonaTask`. Bộ lọc gửi query `status=0` hoặc `status=1`. Sang `task_screen.dart`, gọi `_loadTasks()` trong `initState()` và khi chọn bộ lọc. Giữ `_tasks` cho tổng số và `_visibleTasks` cho danh sách đang xem. Dùng `_loadVersion` để bỏ qua phản hồi cũ nếu người dùng đổi bộ lọc liên tiếp.

### Bước 4. Nối form thêm công việc

Trong `lib/widgets/add_task_form.dart`, cắt khoảng trắng đầu cuối của tên và mô tả, rồi chặn tên rỗng. Truyền `_addTask` vào `AddTaskForm(onAdd: _addTask)`. Trong `SonaTaskApi.createTask`, gửi JSON có `name` và `description`. Khi thành công, màn hình lưu ưu tiên tạm theo ID, tải lại danh sách và form xóa dữ liệu đã nhập.

### Bước 5. Nối checkbox đổi trạng thái

Trong `TaskCard`, đặt giá trị checkbox theo `task.isDone` và nối callback đến `_toggleTask`. Phương thức `updateStatusTask` gửi POST đến ID tương ứng. Vô hiệu hóa checkbox trong lúc gửi cho ID đó. Thành công thì tải lại danh sách, thất bại thì hiển thị thông báo lỗi.

```dart
body: jsonEncode({'status': isDone ? 1 : 0}),
```


## 4. Thực hành và kiểm tra kết quả

1. Mở tab **Task**, chọn **Tất cả**. Chờ thanh tải biến mất và ghi lại số công việc hiện có.
2. Bấm **Lưu công việc** khi tên để trống. Ứng dụng phải báo cần nhập tên và số công việc vẫn giữ nguyên.
3. Nhập tên dễ nhận biết, ví dụ **B10 Ôn tập Flutter**, thêm mô tả rồi bấm **Lưu công việc**. Xác nhận form đã được xóa và tổng số tăng thêm một nếu dữ liệu chung không có thay đổi khác.
4. Chọn **Chưa hoàn thành**, tìm công việc vừa tạo và bấm checkbox. Chuyển sang **Đã hoàn thành**. Công việc phải xuất hiện với tên gạch ngang và trạng thái **Đã xong**.
5. Tắt hẳn rồi mở lại ứng dụng. Vào tab **Task** và chọn **Đã hoàn thành** để xác nhận máy chủ đã lưu trạng thái. Dùng công việc thực hành của mình khi đổi trạng thái trên máy chủ dùng chung.

## 5. Kiểm tra khi danh sách tải lỗi

Kiểm tra mạng và gọi thử endpoint chỉ đọc từ PowerShell.

```powershell
$base = 'https://sona.somee.com/api/v1'
(Invoke-RestMethod "$base/SonaTask/GetAll").result.status
flutter analyze
flutter test
```

Nếu dùng backend cục bộ, mở terminal ở thư mục ESAPAPI đã cấu hình SQL Server phát triển. Chạy `dotnet run --launch-profile http` và giữ terminal đó mở. Từ terminal ở thư mục Flutter, chạy lệnh dưới đây. Địa chỉ `10.0.2.2` của Android Emulator trỏ về máy chạy backend.

```powershell
$taskApi = 'http://10.0.2.2:5279'
flutter run -d emulator-5554 --dart-define=SONATASK_API_URL=$taskApi
```
