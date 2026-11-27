# Bài 10 Kết nối SonaTasks với REST API

Trong bài này, bạn kết nối màn hình Task của Flutter với ESAPAPI. Khi hoàn thành, bạn có thể tải danh sách, lọc theo trạng thái, tạo công việc và đánh dấu hoàn thành. Máy chủ lưu trạng thái công việc để dùng lại khi mở ứng dụng.

## 1. Chuẩn bị và chạy trên Android

Mở PowerShell tại thư mục `flutter_dev_01`. Chuyển sang nhánh `Bai_10` khi thư mục làm việc sạch. Mở Android Emulator trước khi chạy ứng dụng.

```powershell
git switch Bai_10
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Nếu mã thiết bị khác, thay `emulator-5554` bằng mã trong `flutter devices`. Trên Android, Bài 10 mặc định gọi `https://sona.somee.com/api/v1`.

## 2. Đọc hợp đồng API

Các đường dẫn sau được nối vào địa chỉ gốc của ESAPAPI. Mỗi phản hồi thành công của các thao tác này có HTTP 200, `result.status = 200` và dữ liệu trong `data`.

| Thao tác | Phương thức và đường dẫn | Dữ liệu gửi |
| --- | --- | --- |
| Tải tất cả | GET /SonaTask/GetAll | Không có |
| Lọc trạng thái | GET /SonaTask/GetTaskByStatus | Query: status=0 hoặc status=1 |
| Tạo công việc | POST /SonaTask/CreateTask | JSON gồm name, description |
| Đổi trạng thái | POST /SonaTask/UpdateStatusTask/{id} | JSON gồm status dạng số |

`status = 0` là chưa hoàn thành và `status = 1` là đã hoàn thành. Khi phân tích JSON, Flutter đổi giá trị này sang `bool` để hiển thị checkbox.

## 3. Theo dõi luồng trong mã nguồn

- `lib/services/sona_task_api.dart` tạo URL, gửi yêu cầu HTTP và chuyển `data` thành đối tượng `SonaTask`.
- `lib/screens/task_screen.dart` gọi API khi mở màn hình, đổi bộ lọc, lưu công việc hoặc bấm checkbox. Sau khi ghi thành công, màn hình tải lại danh sách và cập nhật số đếm.
- `lib/widgets/add_task_form.dart` kiểm tra tên công việc trước khi gửi. Mức ưu tiên được giữ trong phiên của ứng dụng.

## 4. Thực hành và kiểm tra kết quả

1. Mở tab **Task**, chọn **Tất cả** và xác nhận danh sách tải thành công.
2. Tạo một công việc thực hành có tên dễ nhận biết. Chọn **Chưa hoàn thành** và tìm công việc vừa tạo.
3. Đánh dấu hoàn thành rồi chọn **Đã hoàn thành**. Xác nhận công việc xuất hiện trong bộ lọc và số đếm đã cập nhật.
4. Mở lại ứng dụng và kiểm tra trạng thái vẫn được lưu. Dùng công việc thực hành của mình khi đổi trạng thái trên máy chủ dùng chung.

## 5. Kiểm tra khi danh sách tải lỗi

Kiểm tra mạng và gọi thử endpoint chỉ đọc từ PowerShell.

```powershell
$base = 'https://sona.somee.com/api/v1'
(Invoke-RestMethod "$base/SonaTask/GetAll").result.status
flutter analyze
flutter test
```

Nếu dùng backend cục bộ, khởi động ESAPAPI với profile `http` và SQL Server phát triển đã được cấu hình. Địa chỉ của Android Emulator trỏ về máy chạy backend là `http://10.0.2.2:5279`.

```powershell
$taskApi = 'http://10.0.2.2:5279'
flutter run -d emulator-5554 --dart-define=SONATASK_API_URL=$taskApi
```
