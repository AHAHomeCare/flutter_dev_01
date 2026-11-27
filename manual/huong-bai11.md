# Bài 11 Đăng ký và đăng nhập SonaTasks

Bài 11 thêm màn hình tài khoản vào ứng dụng Bài 10. Khi chưa có phiên hợp lệ, ứng dụng mở màn hình Đăng nhập. Sau khi xác thực thành công, người dùng vào SonaTasks và có thể đăng xuất từ mục Tài khoản.

## 1. Chạy ứng dụng

Mở PowerShell trong thư mục `flutter_dev_01` và khởi động Android Emulator. Khi thư mục làm việc sạch, chuyển sang nhánh Bài 11.

```powershell
git switch Bai_11
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Thay mã thiết bị theo `flutter devices` nếu cần. API tài khoản mặc định là `https://sona.somee.com/api/v1` và yêu cầu HTTPS. Có thể chỉ định máy chủ HTTPS khác bằng `SONATASK_ACCOUNT_API_URL`. Địa chỉ API Task được cấu hình riêng bằng `SONATASK_API_URL`.

## 2. Hiểu hợp đồng tài khoản

Cả hai yêu cầu dùng phương thức POST và gửi JSON có `email` và `password`. Email tối đa 254 ký tự. Mật khẩu dài từ 8 đến 128 ký tự.

| Đường dẫn | Thành công | Dữ liệu cần đọc |
| --- | --- | --- |
| /Account/Register | HTTP 201 | data.id, data.email |
| /Account/Login | HTTP 200 | data.tokenType, data.accessToken, data.expiresIn |

`result.status` nằm trong phản hồi JSON. Khi đăng nhập, `tokenType` là `Bearer` và `expiresIn` là thời hạn theo giây. Dùng email thực hành và mật khẩu riêng cho bài học.

## 3. Theo dõi luồng trong mã nguồn

- `lib/screens/account_screen.dart` hiển thị biểu mẫu, kiểm tra dữ liệu và chuyển từ Đăng ký về Đăng nhập sau khi tạo tài khoản.
- `lib/services/account_api.dart` gọi ESAPAPI, đọc phản hồi và tạo phiên có thời hạn.
- `lib/main.dart` giữ phiên trong bộ nhớ và quyết định hiển thị màn hình tài khoản hay SonaTasks. `lib/screens/app_shell.dart` mở mục Tài khoản và cho phép đăng xuất.

## 4. Thực hành và kiểm tra kết quả

1. Mở app và xác nhận màn hình đầu tiên là **Đăng nhập**.
2. Chọn **Chưa có tài khoản? Đăng ký**. Nhập email và mật khẩu thực hành. Khi đăng ký thành công, ứng dụng trở về biểu mẫu Đăng nhập và giữ email đã nhập.
3. Nhập mật khẩu rồi bấm **Đăng nhập**. Xác nhận app vào SonaTasks, mở mục **Tài khoản** và kiểm tra email hiển thị đúng.
4. Chọn **Đăng xuất**. Màn hình Đăng nhập phải xuất hiện lại. Ứng dụng cũng quay về màn hình này khi phiên hết hạn. Vì phiên chỉ lưu trong bộ nhớ, tắt hẳn app rồi mở lại sẽ yêu cầu đăng nhập lại.

## 5. Kiểm tra lỗi và chạy bộ test

| Tình huống | Kết quả mong đợi |
| --- | --- |
| Email không hợp lệ hoặc mật khẩu quá ngắn | Biểu mẫu hiển thị lỗi trước khi gửi |
| Sai email hoặc mật khẩu | API trả 401 và app báo sai thông tin |
| Email đã đăng ký | API trả 409 và app báo trùng email |
| Gửi yêu cầu quá nhiều lần | API trả 429 và app yêu cầu chờ |

```powershell
flutter analyze
flutter test
```

Bộ kiểm thử dùng API giả lập để kiểm tra luồng đăng ký, đăng nhập và đăng xuất. Kiểm tra trực tiếp trên Somee bằng tài khoản thực hành được cấp hoặc tự đăng ký cho bài học.
