import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/reservation.dart';
import '../providers/reservation_provider.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final Reservation reservation;
  const ReservationDetailsScreen({super.key, required this.reservation});

  @override
  State<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen> {
  bool _loading = false;
  static const _bg = Color(0xFFF6F1EB);
  static const _card = Color(0xFFFBF7F2);
  static const _border = Color(0xFFE2D6CB);
  static const _appBar = Color(0xFF7A563E);
  static const _accent = Color(0xFF6F4BB8);
  static const _textDark = Color(0xFF1F1F1F);

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;

    final dt = r.reservationDateTime;
    final dateStr = dt == null ? "-" : DateFormat('dd.MM.yyyy').format(dt);

    final statusText = (r.status ?? "-").trim();
    final isCancelled = statusText.toLowerCase() == "cancelled";

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _appBar,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("Reservation details"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderCard(
                title: "Reservation",
                subtitle: "Review details and status",
                status: statusText.isEmpty ? "-" : statusText,
                isCancelled: isCancelled,
                cardColor: _card,
                borderColor: _border,
                accent: _accent,
                textDark: _textDark,
              ),
              const SizedBox(height: 14),
              _InfoCard(
                cardColor: _card,
                borderColor: _border,
                children: [
                  _DetailRow(
                    icon: Icons.table_restaurant_outlined,
                    label: "Table",
                    value: "${r.tableNumber ?? r.tableId ?? '-'}",
                    accent: _accent,
                    textDark: _textDark,
                  ),
                  const _DividerLine(),
                  _DetailRow(
                    icon: Icons.event_outlined,
                    label: "Date",
                    value: dateStr,
                    accent: _accent,
                    textDark: _textDark,
                  ),
                  const _DividerLine(),
                  _DetailRow(
                    icon: Icons.group_outlined,
                    label: "Guests",
                    value: "${r.numberOfGuests ?? '-'}",
                    accent: _accent,
                    textDark: _textDark,
                  ),
                  const _DividerLine(),
                  _DetailRow(
                    icon: Icons.info_outline,
                    label: "Status",
                    value: statusText.isEmpty ? "-" : statusText,
                    accent: _accent,
                    textDark: _textDark,
                    trailing: _StatusChip(
                      status: statusText.isEmpty ? "-" : statusText,
                      accent: _accent,
                      borderColor: _border,
                      textDark: _textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _loading || isCancelled
                      ? null
                      : () => _cancelReservation(context, r),
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    disabledBackgroundColor: _accent.withOpacity(0.35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel_outlined),
                  label: Text(isCancelled ? "Cancelled" : "Cancel reservation"),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isCancelled
                    ? "This reservation is already cancelled."
                    : "You can cancel anytime before your visit.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.black54,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancelReservation(BuildContext context, Reservation r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        surfaceTintColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Cancel reservation?"),
        content:
            const Text("Are you sure you want to cancel this reservation?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("No"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
            ),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _loading = true);

    try {
      final provider = context.read<ReservationProvider>();
      await provider.cancelReservation(r.id!, r);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Reservation cancelled.")),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final bool isCancelled;

  final Color cardColor;
  final Color borderColor;
  final Color accent;
  final Color textDark;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.isCancelled,
    required this.cardColor,
    required this.borderColor,
    required this.accent,
    required this.textDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 10),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Icon(
              isCancelled ? Icons.event_busy : Icons.event_available,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ],
            ),
          ),
          _StatusChip(
            status: status,
            accent: accent,
            borderColor: borderColor,
            textDark: textDark,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  final Color cardColor;
  final Color borderColor;

  const _InfoCard({
    required this.children,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 10),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  final Color accent;
  final Color textDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    required this.textDark,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.black54,
          fontWeight: FontWeight.w700,
        );

    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: textDark,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: 3),
                Text(value, style: valueStyle),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Divider(height: 1),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  final Color accent;
  final Color borderColor;
  final Color textDark;

  const _StatusChip({
    required this.status,
    required this.accent,
    required this.borderColor,
    required this.textDark,
  });

  @override
  Widget build(BuildContext context) {
    final s = status.trim().isEmpty ? "-" : status.trim();
    final lower = s.toLowerCase();

    IconData icon;
    Color bg;
    Color fg;

    if (lower == "cancelled") {
      icon = Icons.cancel_outlined;
      fg = Colors.red.shade700;
      bg = Colors.red.shade50;
    } else if (lower == "confirmed") {
      icon = Icons.check_circle_outline;
      fg = Colors.green.shade700;
      bg = Colors.green.shade50;
    } else if (lower == "pending") {
      icon = Icons.hourglass_bottom;
      fg = Colors.orange.shade800;
      bg = Colors.orange.shade50;
    } else {
      icon = Icons.info_outline;
      fg = accent;
      bg = accent.withOpacity(0.10);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            s,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
