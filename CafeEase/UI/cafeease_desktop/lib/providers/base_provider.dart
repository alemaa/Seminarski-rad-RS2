import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/search_result.dart';
import '../utils/authorization.dart';

abstract class BaseProvider<T> with ChangeNotifier {
  static String? _baseUrl;
  final String _endpoint;

  BaseProvider(this._endpoint) {
    _baseUrl = const String.fromEnvironment(
      'baseUrl',
      defaultValue: 'https://localhost:44380/',
    );
  }

  Future<SearchResult<T>> get({dynamic filter}) async {
    var url = '$_baseUrl$_endpoint';

    if (filter != null) {
      url += '?${getQueryString(filter)}';
    }

    var response = await http.get(
      Uri.parse(url),
      headers: createHeaders(),
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    }

    var data = jsonDecode(response.body);
    var result = SearchResult<T>()
      ..count = data['count'];

    for (var item in data['result']) {
      result.result.add(fromJson(item));
    }

    return result;
  }

  Map<String, String> createHeaders() {
    final basicAuth = 'Basic ${base64Encode(
      utf8.encode('${Authorization.username}:${Authorization.password}'),
    )}';

    return {
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };
  }

  T fromJson(dynamic data);

  String getQueryString(Map params) {
    return params.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }
}
