import 'package:flutter/material.dart';

import '../state/dashboard_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/hardware_panel.dart';
import '../widgets/recommendation_panel.dart';

class TwinDetailScreen extends StatelessWidget {
  const TwinDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DashboardScope.of(context);
    final twin = controller.selectedTwin;
    if (twin == null) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= 1100;

    final hardware = HardwarePanel(
      original: twin.build,
      simulation: controller.selectedSimulation,
      onRemoveSimulation: controller.removeSimulation,
    );
    final recommendations = RecommendationPanel(
      category: controller.recommendationCategory,
      recommendations: controller.recommendations,
      generating: controller.generatingRecommendations,
      missingMotherboard: twin.build.motherboard == null,
      simulatedPart: controller.selectedSimulation.partFor(controller.recommendationCategory),
      onCategory: controller.setRecommendationCategory,
      onGenerate: () => controller.generateRecommendations(),
      onSimulate: controller.simulateRecommendation,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Voltar à frota',
              onPressed: controller.clearSelection,
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    twin.displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    'ID ${twin.machineId} · atualizado em ${formatDateTime(twin.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.65),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: SingleChildScrollView(child: hardware)),
                    const SizedBox(width: 16),
                    Expanded(child: SingleChildScrollView(child: recommendations)),
                  ],
                )
              : ListView(
                  children: [
                    hardware,
                    const SizedBox(height: 16),
                    recommendations,
                  ],
                ),
        ),
      ],
    );
  }
}
