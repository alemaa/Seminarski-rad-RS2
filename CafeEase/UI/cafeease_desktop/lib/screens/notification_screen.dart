import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool showUnreadOnly = false;
  bool loading = true;
  String? error;
  List<AppNotification> items = [];

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final provider = context.read<NotificationProvider>();
      final res = await provider.get(
        filter: {
          if (showUnreadOnly) "isRead": false,
          "page": 0,
          "pageSize": 50,
        },
      );
      setState(() {
        items = res.result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          IconButton(
            tooltip: "Mark all as read",
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await context.read<NotificationProvider>().markAllRead();
              await _load();
            },
          ),
          Switch(
            value: showUnreadOnly,
            onChanged: (v) async {
              setState(() => showUnreadOnly = v);
              await _load();
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : items.isEmpty
          ? const Center(child: Text("No notifications"))
          : ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final n = items[i];
                final unread = (n.isRead ?? false) == false;

                return ListTile(
                  title: Text(
                    n.title ?? "",
                    style: TextStyle(
                      fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(n.body ?? ""),
                  trailing: unread
                      ? TextButton(
                          child: const Text("Mark read"),
                          onPressed: () async {
                            if (n.id == null) return;
                            await context.read<NotificationProvider>().markRead(
                              n.id!,
                            );
                            await _load();
                          },
                        )
                      : const Icon(Icons.check, size: 18),
                );
              },
            ),
    );
  }
}
