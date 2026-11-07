import 'package:flutter/material.dart';

import '../models/digital_twin.dart';
import '../models/pc_build.dart';
import '../theme/app_theme.dart';
import 'stat_card.dart';

String _ramNames(PcBuild build) {
  if (build.ram.isEmpty) return 'Não identificado';
  return build.ram.map((item) => item.name).join(' + ');
}

class BuildHistoryPanel extends StatelessWidget {
  const BuildHistoryPanel({super.key, required this.history});

  final List<HardwareSnapshot> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'HISTÓRICO',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Últimos builds',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aparece depois de um upgrade confirmado. A configuração atual fica acima; aqui ficam as builds anteriores.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 16),
            ...history.map((snapshot) => _HistoryEntry(snapshot: snapshot)),
          ],
        ),
      ),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({required this.snapshot});

  final HardwareSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final build = snapshot.build;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFDE68A).withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const StatusBadge(label: 'Build anterior', tone: BadgeTone.history),
                const Spacer(),
                Text(
                  formatDateTime(snapshot.capturedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _Spec(label: 'CPU', value: build.cpu?.name ?? 'Não identificado'),
            _Spec(label: 'RAM', value: _ramNames(build)),
            _Spec(label: 'GPU', value: build.gpuSummary),
            _Spec(label: 'Armazenamento', value: build.storageSummary),
          ],
        ),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
