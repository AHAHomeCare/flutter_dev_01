# SonaTasks · Bài 09 — Gọi REST API

Bài này kế thừa ba màn hình Home, Task và About từ Bài 03. Màn hình Task dùng lớp `SonaTaskApi` trong `lib/services/sona_task_api.dart`.

| Thao tác trên màn hình Task | API |
| --- | --- |
| Tải danh sách khi khởi động, nhấn Tải lại hoặc Thử lại | `GET /SonaTask/GetAll` |
| Nhấn Lưu công việc | `POST /SonaTask/Create` với `name` và `description` |

Khi lưu thành công, ứng dụng dùng bản ghi và ID do API trả về để cập nhật danh sách. Khi lưu lỗi, biểu mẫu giữ lại nội dung đã nhập. Nếu mất kết nối khi gửi yêu cầu, hãy tải lại danh sách để kiểm tra công việc đã được tạo hay chưa trước khi gửi lại.

API chỉ lưu tên và mô tả. Checkbox hoàn thành, độ ưu tiên và bộ lọc hoạt động trong phiên mở ứng dụng.

## Chạy trên máy phát triển

Đặt project ESAPAPI từ bộ mã nguồn khóa học cạnh thư mục Flutter theo đường dẫn bên dưới, hoặc dùng địa chỉ của một ESAPAPI đang chạy. Chạy backend trong terminal thứ nhất. Backend sử dụng SQLite và cần bảng SonaTasks đã được tạo.

```powershell
dotnet run --project "../API DotNetCore/ESAPAPI/ESAPAPI.csproj" --launch-profile http
```

Trong terminal thứ hai:

```powershell
flutter pub get
flutter run -d windows
```

Windows mặc định gọi `http://localhost:5279`. Android Emulator mặc định gọi `http://10.0.2.2:5279`. Với thiết bị thật, truyền địa chỉ backend có thể truy cập từ thiết bị qua `--dart-define=SONATASK_API_URL=<base-url>`. HTTP trên Android được bật cho bản debug. Flutter Web cần cấu hình CORS ở backend nếu chạy khác origin.

Mở tab **Task**, nhập tên và mô tả, nhấn **Lưu công việc**, rồi nhấn **Tải lại danh sách** để kiểm tra công việc đã được lưu trên server.

```powershell
flutter analyze
flutter test
```

Đọc [hướng dẫn mã gọi API theo từng dòng](manual/01-huong-dan-code-call-api.md).

[Bản Word của hướng dẫn](manual/01-huong-dan-code-call-api.docx).
