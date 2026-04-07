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
  static const softBrown = Color(0xFFE6D4C3);
  static const textBrown = Color(0xFF4E342E);

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

  Future<void> _markAllRead() async {
    await context.read<NotificationProvider>().markAllRead();
    await _load();
  }

  Future<void> _markOneRead(AppNotification n) async {
    if (n.id == null) return;
    await context.read<NotificationProvider>().markRead(n.id!);
    await _load();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  String _formatDate(dynamic value) {
    if (value == null) return "";
    try {
      final dt = value is DateTime ? value : DateTime.parse(value.toString());
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return "$day.$month.$year  $hour:$minute";
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBeige,
      appBar: AppBar(
        backgroundColor: primaryBrown,
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: softBrown,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: primaryBrown,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Your notifications",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textBrown,
                          ),
                        ),
                      ),
                      _DesktopFilterChip(
                        label: "Unread only",
                        selected: showUnreadOnly,
                        onTap: () async {
                          setState(() => showUnreadOnly = !showUnreadOnly);
                          await _load();
                        },
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _load,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Refresh"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryBrown,
                          side: const BorderSide(color: primaryBrown),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: items.isEmpty ? null : _markAllRead,
                        icon: const Icon(Icons.done_all),
                        label: const Text("Mark all as read"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBrown,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F4EF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : error != null
                        ? _StateBox(
                            icon: Icons.error_outline_rounded,
                            title: "Something went wrong",
                            subtitle: error!,
                          )
                        : items.isEmpty
                        ? _StateBox(
                            icon: Icons.notifications_off_rounded,
                            title: "No notifications",
                            subtitle: showUnreadOnly
                                ? "You have no unread notifications."
                                : "You're all caught up.",
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) {
                                final n = items[i];
                                final unread = (n.isRead ?? false) == false;

                                return _NotificationDesktopCard(
                                  notification: n,
                                  unread: unread,
                                  formattedDate: _formatDate(n.createdAt),
                                  onMarkRead: () => _markOneRead(n),
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DesktopFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const primaryBrown = Color(0xFF7B5E57);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primaryBrown.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? primaryBrown : const Color(0xFFE0D2C5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: primaryBrown,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onTap,
                child: const Icon(Icons.close, size: 16, color: primaryBrown),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationDesktopCard extends StatelessWidget {
  final AppNotification notification;
  final bool unread;
  final String formattedDate;
  final VoidCallback onMarkRead;

  const _NotificationDesktopCard({
    required this.notification,
    required this.unread,
    required this.formattedDate,
    required this.onMarkRead,
  });

  static const primaryBrown = Color(0xFF7B5E57);
  static const softBrown = Color(0xFFE6D4C3);
  static const textBrown = Color(0xFF4E342E);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: unread ? const Color(0xFFFFFCF8) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: unread ? onMarkRead : null,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: unread ? const Color(0xFFE5D2C5) : const Color(0xFFEEE4DA),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: softBrown,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  unread
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: primaryBrown,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? "",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: unread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: textBrown,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 10),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: primaryBrown,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.body ?? "",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              unread
                  ? TextButton.icon(
                      onPressed: onMarkRead,
                      icon: const Icon(Icons.done, size: 18),
                      label: const Text("Mark read"),
                      style: TextButton.styleFrom(
                        foregroundColor: primaryBrown,
                      ),
                    )
                  : const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StateBox({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  static const primaryBrown = Color(0xFF7B5E57);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE6D8CD)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: primaryBrown),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4E342E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(height: 1.4, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
