# Bài 11 Đăng ký và đăng nhập SonaTasks

Bài 11 thêm màn hình tài khoản vào ứng dụng Bài 10. Khi chưa có phiên hợp lệ, ứng dụng mở màn hình Đăng nhập. Sau khi xác thực thành công, người dùng vào SonaTasks và có thể đăng xuất từ mục Tài khoản.

## 1. Chạy ứng dụng

Mở PowerShell trong thư mục `flutter_dev_01` và khởi động Android Emulator. Khi thư mục làm việc sạch, chuyển sang nhánh Bài 11.

```powershell
git fetch origin
git switch Bai_11
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Thay mã thiết bị theo `flutter devices` nếu cần. API tài khoản mặc định là `https://sona.somee.com/api/v1` và yêu cầu HTTPS. Có thể chỉ định máy chủ HTTPS khác bằng `SONATASK_ACCOUNT_API_URL`. Địa chỉ API Task được cấu hình riêng bằng `SONATASK_API_URL`.

Nếu chưa có máy ảo đang chạy, dùng `flutter emulators` để tìm ID rồi chạy `flutter emulators --launch <id>`. Khi Android đã vào màn hình chính, chạy lại `flutter devices`.

## 2. Hiểu hợp đồng tài khoản

Cả hai yêu cầu dùng phương thức POST và gửi JSON có `email` và `password`. Email tối đa 254 ký tự. Mật khẩu dài từ 8 đến 128 ký tự.

| Đường dẫn | Thành công | Dữ liệu cần đọc |
| --- | --- | --- |
| /Account/Register | HTTP 201 | data.id, data.email |
| /Account/Login | HTTP 200 | data.tokenType, data.accessToken, data.expiresIn |

`result.status` nằm trong phản hồi JSON. Khi đăng nhập, `tokenType` là `Bearer` và `expiresIn` là thời hạn theo giây. Dùng email thực hành và mật khẩu riêng cho bài học.

## 3. Triển khai từng bước trong Flutter

### Bước 1. Tạo lớp gọi API tài khoản

Mở `lib/services/account_api.dart`. Khai báo `AccountSession` với email, access token và thời điểm hết hạn. Trong `AccountApi`, dùng hàm chung `_submit` để nối địa chỉ HTTPS với `/Account/Register` hoặc `/Account/Login`. Gửi JSON qua POST với `Content-Type: application/json; charset=utf-8`. Kiểm tra mã HTTP và `result.status` trước khi dùng `data`.

```dart
body: jsonEncode({'email': email, 'password': password}),
```

### Bước 2. Đọc token và thời hạn đăng nhập

Trong `AccountApi.login`, xác nhận `tokenType` là Bearer, token có giá trị và `expiresIn` là số nguyên dương. Tạo `AccountSession` với thời điểm hết hạn bằng thời điểm hiện tại cộng số giây API trả về. Với `register`, chờ HTTP 201 rồi cho người dùng đăng nhập với mật khẩu của họ.

### Bước 3. Tạo biểu mẫu Đăng nhập và Đăng ký

Mở `lib/screens/account_screen.dart`. Dùng một `Form` với hai `TextFormField` cho email và mật khẩu. Dùng biến `_register` để chuyển chế độ. Trước khi gửi, cắt khoảng trắng của email, giữ nguyên mật khẩu và xác thực cả hai trường. Khóa nút gửi trong lúc chờ. Nếu đăng ký thành công, giữ email, xóa mật khẩu và chuyển về Đăng nhập. Nếu đăng nhập thành công, chuyển phiên lên ứng dụng qua `onSignedIn`.

### Bước 4. Chọn màn hình lúc khởi động

Trong `lib/main.dart`, giữ `_session` trong state của `SonaTasksApp`. Khi chưa có phiên, gán `AccountScreen` cho `MaterialApp.home`. Khi `_signIn` lưu phiên, `setState` dựng lại `home` thành `AppShell`. Bộ hẹn giờ được tạo theo `session.expiresAt`.

```dart
home: session != null
    ? AppShell(api: widget.api, session: session, onSignOut: _signOut)
    : AccountScreen(api: _accountApi, onSignedIn: _signIn),
```

### Bước 5. Nối nút Đăng xuất

Trong `lib/screens/app_shell.dart`, mở hộp thoại Tài khoản, hiển thị email của phiên và gọi `onSignOut` khi người dùng chọn Đăng xuất. Hàm `_signOut` trong `main.dart` hủy bộ hẹn giờ, đóng các màn hình phụ và xóa phiên để app quay lại Đăng nhập. Bộ hẹn giờ gọi cùng hàm này khi hết hạn.


## 4. Thực hành và kiểm tra kết quả

1. Mở app và xác nhận màn hình đầu tiên là **Đăng nhập**. Bấm **Đăng nhập** khi để trống biểu mẫu và kiểm tra các lỗi nhập liệu.
2. Chọn **Chưa có tài khoản? Đăng ký**. Nhập email thực hành chưa đăng ký và mật khẩu đủ độ dài. Bấm **Đăng ký** một lần và chờ phản hồi. Khi thành công, ứng dụng trở về biểu mẫu Đăng nhập, giữ email và xóa mật khẩu.
3. Nhập lại mật khẩu rồi bấm **Đăng nhập**. Xác nhận app vào SonaTasks và hiển thị các tab Home, Task và About. Mở mục **Tài khoản** và kiểm tra email hiển thị đúng.
4. Chọn **Đăng xuất**. Kiểm tra màn hình Đăng nhập xuất hiện và thanh điều hướng của SonaTasks biến mất.
5. Đăng nhập lại, tắt hẳn app rồi mở lại. App yêu cầu đăng nhập lại vì phiên chỉ lưu trong bộ nhớ. Khi phiên hết hạn, ứng dụng cũng tự quay về màn hình Đăng nhập.

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
