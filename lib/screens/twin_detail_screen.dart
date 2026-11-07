import 'package:flutter/material.dart';

import '../state/dashboard_controller.dart';
import '../state/dashboard_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/build_history_panel.dart';
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
      onConfirmSimulation: () => _confirmUpgrade(context, controller),
    );
    final history = BuildHistoryPanel(history: twin.history);
    final recommendations = RecommendationPanel(
      category: controller.recommendationCategory,
      recommendations: controller.recommendations,
      generating: controller.generatingRecommendations,
      missingMotherboard: twin.build.motherboard == null,
      simulatedPart: controller.selectedSimulation.partFor(controller.recommendationCategory),
      onCategory: controller.setRecommendationCategory,
      onGenerate: () => controller.generateRecommendations(),
      onSimulate: controller.simulateRecommendation,
      onConfirmSimulation: () => _confirmUpgrade(context, controller),
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
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            hardware,
                            if (twin.hasUpgradeHistory) ...[
                              const SizedBox(height: 16),
                              history,
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: SingleChildScrollView(child: recommendations)),
                  ],
                )
              : ListView(
                  children: [
                    hardware,
                    if (twin.hasUpgradeHistory) ...[
                      const SizedBox(height: 16),
                      history,
                    ],
                    const SizedBox(height: 16),
                    recommendations,
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _confirmUpgrade(BuildContext context, DashboardController controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar upgrade'),
        content: const Text(
          'A simulação passa a ser a configuração atual desta máquina. A build de agora entra no histórico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    controller.confirmSimulation();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upgrade confirmado. A build anterior foi guardada no histórico.')),
    );
  }
}
