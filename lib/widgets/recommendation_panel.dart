import 'package:flutter/material.dart';

import '../models/compatibility.dart';
import '../models/digital_twin.dart';
import '../models/parts.dart';
import 'stat_card.dart';

class RecommendationPanel extends StatelessWidget {
  const RecommendationPanel({
    super.key,
    required this.category,
    required this.recommendations,
    required this.generating,
    required this.onCategory,
    required this.onGenerate,
    this.missingMotherboard = false,
  });

  final RecommendationCategory category;
  final List<MvpRecommendation> recommendations;
  final bool generating;
  final ValueChanged<RecommendationCategory> onCategory;
  final VoidCallback onGenerate;
  final bool missingMotherboard;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ENGINE LOCAL',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Recomendações de upgrade',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'A mesma engine do agente local: catálogo, regras de compatibilidade e ranking de RAM, SSD e GPU.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RecommendationCategory.values.map((item) {
                final selected = item == category;
                return ChoiceChip(
                  label: Text(item.label),
                  selected: selected,
                  onSelected: generating ? null : (_) => onCategory(item),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: generating ? null : onGenerate,
              icon: generating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(generating ? 'Analisando catálogo…' : 'Gerar recomendações'),
            ),
            const SizedBox(height: 20),
            if (missingMotherboard)
              const Text(
                'Não foi possível recomendar com confiança: a placa-mãe deste Digital Twin não está identificada.',
              )
            else if (recommendations.isEmpty)
              const Text('Selecione uma categoria e gere as recomendações compatíveis.')
            else
              ...recommendations.map((item) => _RecommendationTile(item: item)),
          ],
        ),
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.item});

  final MvpRecommendation item;

  @override
  Widget build(BuildContext context) {
    final part = item.part;
    final extra = switch (part) {
      Ram() => '${part.capacityGb} GB ${part.type} ${part.speedMhz} MHz',
      Ssd() => '${part.capacityGb} GB ${part.interfaceType} ${part.formFactor}',
      Gpu() => '${part.vramGb} GB VRAM · ${part.tdp}W',
      _ => part.brand,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    part.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                StatusBadge(
                  label: item.result.statusLabel,
                  tone: item.result.status == CompatibilityStatus.compatible
                      ? BadgeTone.ok
                      : BadgeTone.warning,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              extra,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(item.result.summary),
            if (item.result.warnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...item.result.warnings.take(2).map(
                    (warning) => Text(
                      warning.message,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
