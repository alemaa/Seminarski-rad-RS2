import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/search_result.dart';
import '../utils/authorization.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  late String _endpoint;

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment(
      'baseUrl',
      defaultValue: 'http://localhost:5003/',
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

    var data = jsonDecode(response.body);

    var result = SearchResult<T>();
    result.count = data['count'];

    for (var item in data['result']) {
      result.result.add(fromJson(item));
    }

    return result;
  }

  Future<T> getById(int id) async {
    var url = '$_baseUrl$_endpoint/$id';
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);

    isValidResponse(response);

    var data = jsonDecode(response.body);
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

    var data = jsonDecode(response.body);
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

    var data = jsonDecode(response.body);
    return fromJson(data);
  }

  Future<void> delete(int id) async {
    var uri = Uri.parse('$_baseUrl$_endpoint/$id');
    var headers = createHeaders();

    var response = await http.delete(uri, headers: headers);

    isValidResponse(response);
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode < 300) return true;

    if (response.statusCode == 403) {
      throw Exception('Desktop access denied.');
    }
    if (response.statusCode == 401) {
      throw Exception('Invalid username or password.');
    }

    final body = response.body.trim();

    if (body.isEmpty) {
      throw Exception('Server error (${response.statusCode}).');
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      throw Exception(body);
    }

    if (decoded is Map && decoded.containsKey('errors')) {
      final errors = decoded['errors'];

      if (errors is Map) {
        final userErr = errors['userError'];
        if (userErr is List && userErr.isNotEmpty) {
          throw Exception(userErr.first.toString());
        }

        if (errors.keys.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstError = errors[firstKey];

          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          }

          if (firstError is String && firstError.isNotEmpty) {
            throw Exception(firstError);
          }
        }
      }
    }

    if (decoded is Map && decoded.containsKey('message')) {
      throw Exception(decoded['message'].toString());
    }

    throw Exception('Unexpected server error (${response.statusCode}).');
  }

  Map<String, String> createHeaders() {
    String username = Authorization.username ?? '';
    String password = Authorization.password ?? '';

    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      headers['X-Client'] = 'Desktop';
    }

    return headers;
  }

  String getQueryString(
    Map params, {
    String prefix = '&',
    bool inRecursion = false,
  }) {
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
