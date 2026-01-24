import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  int? id;
  String? method;
  String? status;
  int? orderId;

  Payment({this.id, this.method, this.status, this.orderId});

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
