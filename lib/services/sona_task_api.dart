import 'dart:convert';

import 'package:http/http.dart' as http;

class SonaTask {
  const SonaTask({
    required this.id,
    required this.name,
    required this.description,
    required this.isDone,
  });

  factory SonaTask.fromJson(Map<String, dynamic> json) => SonaTask(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    isDone: (json['status'] as int) == 1,
  );

  final int id;
  final String name;
  final String description;
  final bool isDone;
}

class SonaTaskApi {
  SonaTaskApi(this._client, this.baseUrl);

  final http.Client _client;
  final String baseUrl;
  static const _timeout = Duration(seconds: 10);
  static const _jsonHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
  };

  Uri _url(String action) =>
      Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/SonaTask/$action');

  Future<List<SonaTask>> getAll() => _getTasks(_url('GetAll'));

  Future<List<SonaTask>> getTaskByStatus(bool isDone) => _getTasks(
    _url('GetTaskByStatus')
        .replace(queryParameters: {'status': isDone ? '1' : '0'}),
  );

  Future<List<SonaTask>> _getTasks(Uri url) async {
    final response = await _client.get(url).timeout(_timeout);
    final items = _data(response) as List<dynamic>;
    return items
        .map((item) => SonaTask.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SonaTask> createTask(String name, String description) async {
    final response = await _client
        .post(
          _url('CreateTask'),
          headers: _jsonHeaders,
          body: jsonEncode({'name': name, 'description': description}),
        )
        .timeout(_timeout);
    return SonaTask.fromJson(_data(response) as Map<String, dynamic>);
  }

  Future<SonaTask> updateStatusTask(int id, bool isDone) async {
    final response = await _client
        .post(
          _url('UpdateStatusTask/$id'),
          headers: _jsonHeaders,
          body: jsonEncode({'status': isDone ? 1 : 0}),
        )
        .timeout(_timeout);
    return SonaTask.fromJson(_data(response) as Map<String, dynamic>);
  }

  Object? _data(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final result = payload['result'] as Map<String, dynamic>;
    if (result['status'] != 200) {
      throw const FormatException('Phản hồi API không thành công.');
    }
    return payload['data'];
  }
}
