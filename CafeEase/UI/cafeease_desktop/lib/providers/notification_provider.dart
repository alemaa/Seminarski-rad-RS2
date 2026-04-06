import 'base_provider.dart';
import '../models/notification.dart';

class NotificationProvider extends BaseProvider<AppNotification> {
  NotificationProvider() : super("api/Notifications");

  @override
  AppNotification fromJson(data) => AppNotification.fromJson(data);

  Future<void> markRead(int id) async {
    await postCustom("api/Notifications/$id/mark-read");
  }

  Future<void> markAllRead() async {
    await postCustom("api/Notifications/mark-all-read");
  }
}
