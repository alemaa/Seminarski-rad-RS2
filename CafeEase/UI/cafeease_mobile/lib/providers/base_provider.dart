import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/search_result.dart';
import '../utils/util.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  late String _endpoint;
  static String get baseUrl => _baseUrl ?? 'http://10.0.2.2:5003/';

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment(
      'baseUrl',
      defaultValue: 'http://10.0.2.2:5003/',
    );
  }
  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = '$_baseUrl$_endpoint';

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = '$url?$queryString';
    }

    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
    isValidResponse(response);

    var data = jsonDecode(utf8.decode(response.bodyBytes));

    SearchResult<T> result = SearchResult<T>();
    result.count = data['count'] ?? 0;

    if (data['result'] != null) {
      for (var item in data['result']) {
        result.result.add(fromJson(item));
      }
    }

    return result;
  }

  Future<T> getById(int id) async {
    var uri = Uri.parse('$_baseUrl$_endpoint/$id');
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
    isValidResponse(response);

    var data = jsonDecode(utf8.decode(response.bodyBytes));
    return fromJson(data);
  }

  Future<T> insert(dynamic request) async {
    var uri = Uri.parse('$_baseUrl$_endpoint');
    var headers = createHeaders();

    var response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(request),
    );

    isValidResponse(response);

    var data = jsonDecode(utf8.decode(response.bodyBytes));
    return fromJson(data);
  }

  Future<T> update(int id, dynamic request) async {
    var uri = Uri.parse('$_baseUrl$_endpoint/$id');
    var headers = createHeaders();

    var response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(request),
    );

    isValidResponse(response);

    var data = jsonDecode(utf8.decode(response.bodyBytes));
    return fromJson(data);
  }

  Future<String> postCustom(String route) async {
    final uri = Uri.parse("$_baseUrl$route");
    final response = await http.post(uri, headers: createHeaders());
    isValidResponse(response);
    return response.body;
  }

  Future<String> deleteCustom(String route) async {
    final uri = Uri.parse("$_baseUrl$route");
    final response = await http.delete(uri, headers: createHeaders());
    isValidResponse(response);

    return response.body;
  }

  Future<dynamic> getCustom(String route) async {
    final uri = Uri.parse("$_baseUrl$route");
    final response = await http.get(uri, headers: createHeaders());
    isValidResponse(response);
    final body = utf8.decode(response.bodyBytes);

    if (body.trim().isEmpty) return null;

    return jsonDecode(body);
  }

  Future<void> updateVoid(int id, dynamic request) async {
    var uri = Uri.parse('$_baseUrl$_endpoint/$id');
    var headers = createHeaders();

    var response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(request),
    );

    isValidResponse(response);
  }

  Future<void> delete(int id) async {
    var uri = Uri.parse('$_baseUrl$_endpoint/$id');
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);
    isValidResponse(response);
  }

  void isValidResponse(http.Response response) {
    if (response.statusCode < 300) return;

    if (response.statusCode == 401) {
      throw Exception("Incorrect username or password");
    }

    if (response.statusCode == 403) {
      throw Exception("Access denied");
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('errors')) {
        if (decoded['errors']['userError'] != null &&
            decoded['errors']['userError'] is List &&
            decoded['errors']['userError'].isNotEmpty) {
          throw Exception(decoded['errors']['userError'][0]);
        }

        final firstKey = decoded['errors'].keys.first;
        final firstError = decoded['errors'][firstKey];
        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError[0]);
        }
      }

      throw Exception('Unexpected server error');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Map<String, String> createHeaders() {
    String username = Authorization.username ?? '';
    String password = Authorization.password ?? '';

    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    return {'Content-Type': 'application/json', 'Authorization': basicAuth};
  }

  String getQueryString(Map params, {String prefix = '&'}) {
    String query = '';

    params.forEach((key, value) {
      if (value == null) return;

      if (value is String || value is int || value is double || value is bool) {
        query += '$prefix$key=${Uri.encodeComponent(value.toString())}';
      } else if (value is DateTime) {
        query += '$prefix$key=${value.toIso8601String()}';
      }
    });

    return query;
  }

  T fromJson(dynamic data);
}
