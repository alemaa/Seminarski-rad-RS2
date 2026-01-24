// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
      id: (json['id'] as num?)?.toInt(),
      method: json['method'] as String?,
      status: json['status'] as String?,
      orderId: (json['orderId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
      'id': instance.id,
      'method': instance.method,
      'status': instance.status,
      'orderId': instance.orderId,
    };
