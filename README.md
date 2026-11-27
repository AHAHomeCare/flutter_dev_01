# SonaTasks Bài 10

Bài 10 kế thừa giao diện Bài 09. Màn hình Task gọi ESAPAPI để đọc tất cả công việc, lọc theo trạng thái, tạo công việc và cập nhật trạng thái. Ưu tiên được lưu trong phiên hiện tại.

## Chuẩn bị backend

ESAPAPI dùng SQL Server. Cấu hình `ConnectionStrings:DefaultConnection` cho cơ sở dữ liệu phát triển đã có bảng `SonaTasks` trong cấu hình cục bộ của ESAPAPI hoặc qua biến môi trường `ConnectionStrings__DefaultConnection`.

Mở PowerShell trong thư mục Flutter và chạy:

```powershell
Set-Location '../API DotNetCore/ESAPAPI'
dotnet run --launch-profile http
```

## Chạy Flutter

Mở terminal khác trong thư mục `Bai09.02`.

```powershell
flutter pub get
flutter run -d windows
```

Windows mặc định dùng `http://localhost:5279`. Android mặc định dùng `https://sona.somee.com/api/v1` theo cấu hình Somee trong ESAPAPI Manual. Để dùng ESAPAPI cục bộ trên Android Emulator, chạy `flutter run --dart-define=SONATASK_API_URL=http://10.0.2.2:5279`.

Mở tab **Task**. Tạo một công việc, chọn **Chưa hoàn thành**, đánh dấu hoàn thành, rồi chọn **Đã hoàn thành** và xác nhận dòng xuất hiện. Đóng và mở lại ứng dụng để kiểm tra trạng thái được lưu.

```powershell
flutter analyze
flutter test
```


Xem [hướng dẫn thực hành từng bước](manual/Bai_09_02_Huong_dan_tung_buoc.docx).
