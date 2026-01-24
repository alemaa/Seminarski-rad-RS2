import 'package:json_annotation/json_annotation.dart';

part 'payment_insert_request.g.dart';

@JsonSerializable()
class PaymentInsertRequest {
  int orderId;
  String method;

  PaymentInsertRequest({required this.orderId, required this.method});

  factory PaymentInsertRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentInsertRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentInsertRequestToJson(this);
}
