import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Authorization {
  static String? username;
  static String? password;

  static int? userId;
}

Image imageFromBase64String(String base64String) {
  return Image.memory(base64Decode(base64String));
}

Uint8List dataFromBase64String(String base64String) {
  return base64Decode(base64String);
}

String base64String(Uint8List data) {
  return base64Encode(data);
}

String formatNumber(dynamic value) {
  if (value == null) {
    return "";
  }

  var f = NumberFormat('#,##0.00');
  return f.format(value);
}
