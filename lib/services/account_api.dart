import 'dart:convert';

import 'package:http/http.dart' as http;

class AccountSession {
  const AccountSession(this.email, this.accessToken, this.expiresAt);

  final String email;
  final String accessToken;
  final DateTime expiresAt;
}

class AccountApiException implements Exception {
  const AccountApiException(this.message);

  final String message;
}

class AccountApi {
  AccountApi(this._client, this.baseUrl);

  final http.Client _client;
  final String baseUrl;

  Future<void> register(String email, String password) async {
    await _submit('Register', email, password, 201);
  }

  Future<AccountSession> login(String email, String password) async {
    final data = await _submit('Login', email, password, 200);
    if (data
        case {
          'tokenType': 'Bearer',
          'accessToken': final String token,
          'expiresIn': final int seconds,
        }
        when token.isNotEmpty && seconds > 0) {
      return AccountSession(
        email,
        token,
        DateTime.now().add(Duration(seconds: seconds)),
      );
    }
    throw const FormatException('Invalid session response');
  }

  Future<Object?> _submit(
    String action,
    String email,
    String password,
    int expectedStatus,
  ) async {
    final uri = Uri.parse(
      '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/Account/$action',
    );
    if (uri.scheme != 'https' || uri.host.isEmpty) {
      throw const AccountApiException('API tài khoản cần địa chỉ HTTPS.');
    }
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != expectedStatus) {
      throw AccountApiException(switch (response.statusCode) {
        400 => 'Vui lòng kiểm tra email và mật khẩu.',
        401 => 'Email hoặc mật khẩu không đúng.',
        409 => 'Email này đã được đăng ký.',
        429 => 'Bạn đã thử quá nhiều lần. Vui lòng thử lại sau.',
        _ => 'API tài khoản hiện không khả dụng. Vui lòng thử lại sau.',
      });
    }
    final payload = jsonDecode(utf8.decode(response.bodyBytes));
    if (payload
        case {
          'result': {'status': final int status},
          'data': final Object? data,
        }
        when status == expectedStatus) {
      return data;
    }
    throw const FormatException('Invalid account response');
  }
}
