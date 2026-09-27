import 'package:flutter/material.dart';

import '../models/digital_twin.dart';
import '../models/pc_build.dart';
import '../models/upgrade_simulation.dart';
import 'stat_card.dart';

class HardwarePanel extends StatelessWidget {
  const HardwarePanel({
    super.key,
    required this.original,
    this.simulation = const UpgradeSimulation(),
    this.onRemoveSimulation,
  });

  final PcBuild original;
  final UpgradeSimulation simulation;
  final ValueChanged<RecommendationCategory>? onRemoveSimulation;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CONFIGURAÇÃO ATUAL',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              simulation.isEmpty ? 'Hardware do Digital Twin' : 'Hardware com simulação',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (simulation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'As peças reais continuam no Firebase. O que está marcado como simulação existe só neste painel.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ],
            const SizedBox(height: 18),
            _Row(label: 'CPU', value: original.cpu?.name ?? 'Não identificado'),
            _Row(label: 'Placa-mãe', value: original.motherboard?.name ?? 'Não identificado'),
            _SimulatedRow(
              label: 'RAM',
              originalValue: original.ramSummary,
              simulatedValue: simulation.ram == null
                  ? null
                  : '${simulation.ram!.capacityGb} GB ${simulation.ram!.type} ${simulation.ram!.speedMhz} MHz · ${simulation.ram!.name}',
              onRemove: simulation.ram == null
                  ? null
                  : () => onRemoveSimulation?.call(RecommendationCategory.ram),
            ),
            _SimulatedRow(
              label: 'GPU',
              originalValue: original.gpuSummary,
              simulatedValue: simulation.gpu?.name,
              onRemove: simulation.gpu == null
                  ? null
                  : () => onRemoveSimulation?.call(RecommendationCategory.gpu),
            ),
            _SimulatedRow(
              label: 'Armazenamento',
              originalValue: original.storageSummary,
              simulatedValue: simulation.ssd == null
                  ? null
                  : '${simulation.ssd!.name} (${simulation.ssd!.capacityGb} GB)',
              onRemove: simulation.ssd == null
                  ? null
                  : () => onRemoveSimulation?.call(RecommendationCategory.ssd),
            ),
            if (original.psu != null) _Row(label: 'Fonte', value: original.psu!.name),
            if (original.pcCase != null) _Row(label: 'Gabinete', value: original.pcCase!.name),
          ],
        ),
      ),
    );
  }
}

class _SimulatedRow extends StatelessWidget {
  const _SimulatedRow({
    required this.label,
    required this.originalValue,
    this.simulatedValue,
    this.onRemove,
  });

  final String label;
  final String originalValue;
  final String? simulatedValue;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final hasSimulation = simulatedValue != null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 6),
          if (hasSimulation) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F).withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF93C5FD).withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const StatusBadge(label: 'Simulação', tone: BadgeTone.simulation),
                      const Spacer(),
                      TextButton(
                        onPressed: onRemove,
                        child: const Text('Remover'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    simulatedValue!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Peça atual: $originalValue',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
          ] else
            Text(
              originalValue,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
