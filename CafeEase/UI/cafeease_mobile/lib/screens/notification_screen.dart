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

  static const primaryBrown = Color(0xFF7B5E57);
  static const lightBeige = Color(0xFFF3EDE8);
  static const accentBrown = Color(0xFFD7CCC8);

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final provider = context.read<NotificationProvider>();
      final res = await provider.get(filter: {
        if (showUnreadOnly) "isRead": false,
        "page": 0,
        "pageSize": 50,
      });

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
      backgroundColor: lightBeige,
      appBar: AppBar(
        backgroundColor: primaryBrown,
        elevation: 0,
        title: const Text("Notifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await context.read<NotificationProvider>().markAllRead();
              await _load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _chip("All", !showUnreadOnly, () async {
                  setState(() => showUnreadOnly = false);
                  await _load();
                }),
                const SizedBox(width: 8),
                _chip("Unread", showUnreadOnly, () async {
                  setState(() => showUnreadOnly = true);
                  await _load();
                }),
              ],
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? _error()
                    : items.isEmpty
                        ? _empty()
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              itemCount: items.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: Colors.brown.withOpacity(0.1),
                              ),
                              itemBuilder: (_, i) {
                                final n = items[i];
                                final unread =
                                    (n.isRead ?? false) == false;

                                return _tile(n, unread);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? primaryBrown : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryBrown),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : primaryBrown,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _tile(AppNotification n, bool unread) {
    return InkWell(
      onTap: () async {
        if (n.id == null) return;
        await context.read<NotificationProvider>().markRead(n.id!);
        await _load();
      },
      child: Container(
        color: unread
            ? primaryBrown.withOpacity(0.06)
            : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentBrown,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications,
                size: 20,
                color: primaryBrown,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title ?? "",
                          style: TextStyle(
                            fontWeight: unread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: primaryBrown,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    n.body ?? "",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Just now",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.brown.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off, size: 50),
          SizedBox(height: 10),
          Text("No notifications"),
        ],
      ),
    );
  }

  Widget _error() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 50),
          const SizedBox(height: 10),
          const Text("Something went wrong"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _load,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}