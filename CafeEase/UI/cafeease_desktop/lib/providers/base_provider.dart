import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/search_result.dart';
import '../utils/authorization.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  late String _endpoint;

  BaseProvider(String endpoint) {
    _endpoint = endpoint;
    _baseUrl = const String.fromEnvironment(
      'baseUrl',
      defaultValue: 'https://localhost:44380/',
    );
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = '$_baseUrl$_endpoint';

    if (filter != null) {
      var queryString = getQueryString(filter);
      url = '$url?$queryString';
    }
print("URL: $url");

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
    if (response.statusCode < 300) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception(
        'Server error (${response.statusCode}): ${response.body}',
      );
    }
  }

  Map<String, String> createHeaders() {
    String username = Authorization.username ?? '';
    String password = Authorization.password ?? '';

    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    return {
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };
  }

  String getQueryString(Map params,
      {String prefix = '&', bool inRecursion = false}) {
    String query = '';

    params.forEach((key, value) {
      if (value == null) return;

      if (value is String ||
          value is int ||
          value is double ||
          value is bool) {
        query += '$prefix$key=${Uri.encodeComponent(value.toString())}';
      } else if (value is DateTime) {
        query += '$prefix$key=${value.toIso8601String()}';
      }
    });

    return query;
  }
  T fromJson(dynamic data);
}
