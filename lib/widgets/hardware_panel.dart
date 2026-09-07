import 'package:flutter/material.dart';

import '../models/pc_build.dart';

class HardwarePanel extends StatelessWidget {
  const HardwarePanel({super.key, required this.pcBuild});

  final PcBuild pcBuild;

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
              'Hardware do Digital Twin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 18),
            _Row(label: 'CPU', value: pcBuild.cpu?.name ?? 'Não identificado'),
            _Row(label: 'Placa-mãe', value: pcBuild.motherboard?.name ?? 'Não identificado'),
            _Row(label: 'RAM', value: pcBuild.ramSummary),
            _Row(label: 'GPU', value: pcBuild.gpuSummary),
            _Row(label: 'Armazenamento', value: pcBuild.storageSummary),
            if (pcBuild.psu != null) _Row(label: 'Fonte', value: pcBuild.psu!.name),
            if (pcBuild.pcCase != null) _Row(label: 'Gabinete', value: pcBuild.pcCase!.name),
          ],
        ),
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
