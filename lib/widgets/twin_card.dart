import 'package:flutter/material.dart';

import '../models/digital_twin.dart';
import '../theme/app_theme.dart';
import 'stat_card.dart';

class TwinCard extends StatelessWidget {
  const TwinCard({
    super.key,
    required this.twin,
    required this.onOpen,
  });

  final RemoteDigitalTwin twin;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final build = twin.build;
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      twin.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  StatusBadge(
                    label: twin.current.source == 'native' ? 'Nativo' : twin.current.source,
                    tone: BadgeTone.ok,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'ID ${shortId(twin.machineId)} · atualizado em ${formatDateTime(twin.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.65),
                    ),
              ),
              const SizedBox(height: 16),
              _Spec(label: 'CPU', value: build.cpu?.name ?? 'Não identificado'),
              _Spec(label: 'Placa-mãe', value: build.motherboard?.name ?? 'Não identificado'),
              _Spec(label: 'RAM', value: build.ramSummary),
              _Spec(label: 'GPU', value: build.gpuSummary),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Gerenciar'),
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
