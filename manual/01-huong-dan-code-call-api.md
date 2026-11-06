# Hướng dẫn đọc mã gọi REST API trong SonaTasks

Bài 09 dùng `SonaTaskApi` để màn hình **Task** tải danh sách và tạo công việc qua ESAPAPI. Mở [sona_task_api.dart](../lib/services/sona_task_api.dart) cùng tài liệu này để đối chiếu số dòng. Các bảng bỏ qua dòng trống.

| Thao tác | Endpoint | Dữ liệu trong `data` |
| --- | --- | --- |
| Tải danh sách | `GET /SonaTask/GetAll` | Mảng công việc |
| Lưu công việc | `POST /SonaTask/Create` | Một công việc có ID do server cấp |

## Model và thư viện

| Dòng | Mã | Giải thích |
| ---: | --- | --- |
| 1 | `import 'dart:convert';` | Nhập `dart:convert` để dùng `jsonEncode`, `jsonDecode` và bộ giải mã UTF-8. |
| 3 | `import 'package:http/http.dart' as http;` | Nhập package `http` với tiền tố `http` để dùng `http.Client` và `http.Response`. |
| 5 | `class SonaTask {` | Khai báo model `SonaTask` đại diện cho một công việc từ server. |
| 6 | `const SonaTask({` | Mở constructor `const` của model. |
| 7 | `required this.id,` | Yêu cầu truyền `id` do server cấp. |
| 8 | `required this.name,` | Yêu cầu truyền `name`, tức tên công việc. |
| 9 | `required this.description,` | Yêu cầu truyền `description`, tức mô tả công việc. |
| 10 | `});` | Kết thúc constructor. |
| 12 | `factory SonaTask.fromJson(Map<String, dynamic> json) => SonaTask(` | Khai báo factory nhận một đối tượng JSON đã được giải mã thành `Map` và trả về `SonaTask`. |
| 13 | `id: json['id'] as int,` | Đọc `id` từ JSON dưới dạng số nguyên. |
| 14 | `name: json['name'] as String,` | Đọc `name` dưới dạng chuỗi. |
| 15 | `description: json['description'] as String? ?? '',` | Đọc mô tả dưới dạng chuỗi có thể null. Nếu thiếu hoặc null, dùng chuỗi rỗng. |
| 16 | `);` | Kết thúc lời gọi constructor trong factory. |
| 18 | `final int id;` | Khai báo ID kiểu `int`, chỉ gán một lần. |
| 19 | `final String name;` | Khai báo tên kiểu `String`, chỉ gán một lần. |
| 20 | `final String description;` | Khai báo mô tả kiểu `String`, chỉ gán một lần. |
| 21 | `}` | Đóng lớp model. |

## Khởi tạo client và ghép URL

| Dòng | Mã | Giải thích |
| ---: | --- | --- |
| 23 | `class SonaTaskApi {` | Khai báo lớp phụ trách gọi API SonaTask. |
| 24 | `SonaTaskApi(this._client, this.baseUrl);` | Nhận client và URL gốc qua constructor. Widget test có thể truyền `MockClient`. |
| 26 | `final http.Client _client;` | Giữ client HTTP để dùng cho cả GET và POST. Dấu `_` giới hạn truy cập trong thư viện Dart. |
| 27 | `final String baseUrl;` | Giữ URL gốc của backend. |
| 29 | `Uri _url(String action) =>` | Khai báo hàm nội bộ nhận tên action và trả về `Uri`. |
| 30 | `Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/SonaTask/$action');` | Bỏ các dấu `/` ở cuối URL gốc, ghép `/SonaTask/` với action rồi chuyển chuỗi thành `Uri`. |

## GET danh sách công việc

| Dòng | Mã | Giải thích |
| ---: | --- | --- |
| 32 | `Future<List<SonaTask>> getAll() async {` | Khai báo `getAll` là hàm bất đồng bộ, trả về danh sách công việc qua `Future`. |
| 33 | `final response = await _client` | Chờ phản hồi HTTP và gán kết quả cho `response`. |
| 34 | `.get(_url('GetAll'))` | Gửi GET đến `/SonaTask/GetAll`. |
| 35 | `.timeout(const Duration(seconds: 10));` | Giới hạn thời gian chờ 10 giây. Quá hạn, `Future` báo lỗi. |
| 36 | `final items = _data(response) as List<dynamic>;` | Dùng `_data` kiểm tra phản hồi và đọc mảng `data`. |
| 37 | `return items` | Bắt đầu trả về danh sách đã chuyển đổi. |
| 38 | `.map((item) => SonaTask.fromJson(item as Map<String, dynamic>))` | Ép mỗi phần tử thành `Map` và dùng `fromJson` để tạo model. |
| 39 | `.toList();` | Chuyển kết quả `map` thành `List<SonaTask>`. |
| 40 | `}` | Đóng hàm `getAll`. |

## POST tạo công việc

| Dòng | Mã | Giải thích |
| ---: | --- | --- |
| 42 | `Future<SonaTask> create(String name, String description) async {` | Khai báo `create` nhận tên và mô tả, trả về bản ghi do server tạo qua `Future`. |
| 43 | `final response = await _client` | Chờ phản hồi HTTP và gán kết quả cho `response`. |
| 44 | `.post(` | Bắt đầu lời gọi HTTP POST. |
| 45 | `_url('Create'),` | Đặt đích là `/SonaTask/Create`. |
| 46 | `headers: {'Content-Type': 'application/json; charset=utf-8'},` | Khai báo request body là JSON mã hóa UTF-8. |
| 47 | `body: jsonEncode({'name': name, 'description': description}),` | Tạo đối tượng gồm `name` và `description`, rồi chuyển thành chuỗi JSON. Server cấp `id`. |
| 48 | `)` | Kết thúc các đối số của POST. |
| 49 | `.timeout(const Duration(seconds: 10));` | Giới hạn thời gian chờ phản hồi POST ở 10 giây. |
| 50 | `return SonaTask.fromJson(_data(response) as Map<String, dynamic>);` | Đọc đối tượng `data`, chuyển thành `SonaTask` và trả về cho màn hình. |
| 51 | `}` | Đóng hàm `create`. |

## Đọc và kiểm tra phản hồi

| Dòng | Mã | Giải thích |
| ---: | --- | --- |
| 53 | `Object? _data(http.Response response) {` | Khai báo hàm đọc `data` dùng chung. Kiểu `Object?` phù hợp với cả mảng của GET và đối tượng của POST. |
| 54 | `if (response.statusCode != 200) {` | Kiểm tra mã trạng thái HTTP theo hợp đồng hiện tại của ESAPAPI. |
| 55 | `throw Exception('HTTP ${response.statusCode}');` | Ném lỗi kèm mã HTTP để kết thúc xử lý nếu server trả mã khác 200. |
| 56 | `}` | Đóng khối kiểm tra HTTP. |
| 57 | `final payload =` | Bắt đầu gán JSON đã giải mã cho `payload`. |
| 58 | `jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;` | Giải mã byte bằng UTF-8 để giữ tiếng Việt, sau đó phân tích JSON và ép đối tượng ngoài cùng thành `Map`. |
| 59 | `if (payload['status'] != 200) {` | Kiểm tra trường `status` trong JSON. Đây là giá trị trong body, tách biệt với mã HTTP. |
| 60 | `throw const FormatException('Phản hồi API không thành công.');` | Ném `FormatException` nếu JSON báo thao tác thất bại. |
| 61 | `}` | Đóng khối kiểm tra `status`. |
| 62 | `return payload['data'];` | Trả phần `data` đã tách khỏi phản hồi. |
| 63 | `}` | Đóng hàm `_data`. |
| 64 | `}` | Đóng lớp `SonaTaskApi`. |

## Màn hình gọi API ở đâu

- [task_screen.dart](../lib/screens/task_screen.dart) dòng 19–27 tạo client, chọn URL gốc và cho phép truyền service giả lập khi kiểm thử. Windows mặc định dùng `http://localhost:5279`, Android Emulator dùng `http://10.0.2.2:5279`. Có thể truyền `--dart-define=SONATASK_API_URL=<base-url>` để đổi địa chỉ.
- Dòng 37–45 gọi `_loadTasks()` khi widget được khởi tạo và đóng client do màn hình sở hữu khi widget bị hủy.
- Dòng 54–75 gọi `await _api.getAll()`. Trong lúc chờ, màn hình hiện vòng tải. Thành công thì thay danh sách và cập nhật số việc chưa xong. Nếu thất bại, màn hình hiện **Thử lại**. Sau `await`, kiểm tra `mounted` trước khi cập nhật giao diện.
- Dòng 78–95 gọi `await _api.create(title, description)`. Thành công thì thêm bản ghi server trả về vào danh sách. Khối `finally` đặt lại trạng thái lưu, kể cả khi lời gọi báo lỗi.
- [add_task_form.dart](../lib/widgets/add_task_form.dart) dòng 19–55 kiểm tra tên và chờ `widget.onAdd(...)`. Thành công thì xóa form. Nếu thất bại thì giữ dữ liệu nhập và hiển thị thông báo. Nút **Lưu công việc** bị vô hiệu hóa trong lúc gửi.

## Ví dụ JSON và kiểm tra

Khi người dùng nhập **Ôn tập Flutter**, POST gửi nội dung sau.

```json
{"name":"Ôn tập Flutter","description":"Thực hành gọi API"}
```

Ví dụ phản hồi POST thành công. GET có cùng dạng bao ngoài nhưng `data` là một mảng.

```json
{
  "status": 200,
  "message": "Insert Success",
  "data": {"id": 102, "name": "Ôn tập Flutter", "description": "Thực hành gọi API"}
}
```

1. Chạy backend và Flutter theo [README](../README.md). Mở **Task** để xem kết quả GET.
2. Tạo một công việc có tên tiếng Việt, rồi nhấn **Tải lại danh sách** để xác nhận bản ghi đã lưu.
3. Dừng backend và nhấn **Tải lại danh sách** để kiểm tra thông báo lỗi. Khởi động lại backend rồi nhấn **Thử lại**.
4. Nếu POST hết thời gian chờ, tải lại danh sách trước khi gửi lại. Server có thể đã lưu công việc trong lúc ứng dụng chờ phản hồi.

API hiện lưu tên và mô tả. Checkbox hoàn thành và độ ưu tiên do màn hình quản lý trong phiên hiện tại.
