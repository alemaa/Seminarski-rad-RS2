import 'package:json_annotation/json_annotation.dart';
part 'notification.g.dart';

@JsonSerializable()
class AppNotification {
  int? id;
  int? userId;
  int? orderId;
  String? title;
  String? body;
  bool? isRead;
  DateTime? createdAt;

  AppNotification({this.id, this.userId, this.orderId, this.title, this.body, this.isRead, this.createdAt});

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}