import 'package:flutter/material.dart';

import '../models/digital_twin.dart';
import '../models/pc_build.dart';
import '../models/upgrade_simulation.dart';
import '../theme/app_theme.dart';
import 'stat_card.dart';

class TwinCard extends StatelessWidget {
  const TwinCard({
    super.key,
    required this.twin,
    required this.onOpen,
    this.simulation = const UpgradeSimulation(),
  });

  final RemoteDigitalTwin twin;
  final VoidCallback onOpen;
  final UpgradeSimulation simulation;

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
                  if (simulation.isNotEmpty) ...[
                    const StatusBadge(label: 'Simulação', tone: BadgeTone.simulation),
                    const SizedBox(width: 8),
                  ],
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
              _Spec(
                label: 'RAM',
                value: simulation.ram?.name ?? _ramNames(build),
                simulated: simulation.ram != null,
                originalValue: simulation.ram == null ? null : build.ramSummary,
              ),
              _Spec(
                label: 'GPU',
                value: simulation.gpu?.name ?? build.gpuSummary,
                simulated: simulation.gpu != null,
                originalValue: simulation.gpu == null ? null : build.gpuSummary,
              ),
              if (simulation.ssd != null)
                _Spec(
                  label: 'SSD',
                  value: simulation.ssd!.name,
                  simulated: true,
                  originalValue: build.storageSummary,
                ),
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

String _ramNames(PcBuild build) {
  if (build.ram.isEmpty) return 'Não identificado';
  return build.ram.map((item) => item.name).join(' + ');
}

class _Spec extends StatelessWidget {
  const _Spec({
    required this.label,
    required this.value,
    this.simulated = false,
    this.originalValue,
  });

  final String label;
  final String value;
  final bool simulated;
  final String? originalValue;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (simulated) ...[
                  const StatusBadge(label: 'Simulação', tone: BadgeTone.simulation),
                  const SizedBox(height: 4),
                ],
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (originalValue != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Atual: $originalValue',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
