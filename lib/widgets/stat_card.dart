import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: colors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.onSurface.withValues(alpha: 0.7))),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.tone = BadgeTone.neutral});

  final String label;
  final BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = switch (tone) {
      BadgeTone.ok => (const Color(0xFF064E3B), const Color(0xFF6EE7B7)),
      BadgeTone.warning => (const Color(0xFF78350F), const Color(0xFFFCD34D)),
      BadgeTone.value => (const Color(0xFF134E4A), const Color(0xFF5EEAD4)),
      BadgeTone.premium => (const Color(0xFF3B0764), const Color(0xFFE9D5FF)),
      BadgeTone.simulation => (const Color(0xFF1E3A5F), const Color(0xFF93C5FD)),
      BadgeTone.neutral => (const Color(0xFF1E293B), const Color(0xFFCBD5E1)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: colors.$1, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(color: colors.$2, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum BadgeTone { ok, warning, value, premium, simulation, neutral }
