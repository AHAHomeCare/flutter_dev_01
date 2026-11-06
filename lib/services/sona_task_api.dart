import 'dart:convert';

import 'package:http/http.dart' as http;

class SonaTask {
  const SonaTask({
    required this.id,
    required this.name,
    required this.description,
  });

  factory SonaTask.fromJson(Map<String, dynamic> json) => SonaTask(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
  );

  final int id;
  final String name;
  final String description;
}

class SonaTaskApi {
  SonaTaskApi(this._client, this.baseUrl);

  final http.Client _client;
  final String baseUrl;

  Uri _url(String action) =>
      Uri.parse('${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/SonaTask/$action');

  Future<List<SonaTask>> getAll() async {
    final response = await _client
        .get(_url('GetAll'))
        .timeout(const Duration(seconds: 10));
    final items = _data(response) as List<dynamic>;
    return items
        .map((item) => SonaTask.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SonaTask> create(String name, String description) async {
    final response = await _client
        .post(
          _url('Create'),
          headers: {'Content-Type': 'application/json; charset=utf-8'},
          body: jsonEncode({'name': name, 'description': description}),
        )
        .timeout(const Duration(seconds: 10));
    return SonaTask.fromJson(_data(response) as Map<String, dynamic>);
  }

  Object? _data(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final payload =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    if (payload['status'] != 200) {
      throw const FormatException('Phản hồi API không thành công.');
    }
    return payload['data'];
  }
}
