import 'package:flutter/material.dart';

import '../screens/twin_detail_screen.dart';
import '../screens/twins_list_screen.dart';
import '../state/dashboard_controller.dart';
import '../state/dashboard_scope.dart';

class DashboardShell extends StatelessWidget {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DashboardScope.of(context);
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _DashboardBody(controller: controller),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          ColoredBox(
            color: const Color(0xFF0A101C),
            child: SizedBox(
              width: 228,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TWINMATCH',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.6,
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gestão de Digital Twins',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 28),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.hub_outlined),
                      title: const Text('Frota'),
                      selected: true,
                      onTap: controller.clearSelection,
                    ),
                    const Spacer(),
                    Text(
                      'Fonte: Firebase Realtime Database',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.55),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 22, 28, 22),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      if (controller.loading)
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      FilledButton.tonalIcon(
                        onPressed: controller.loading
                            ? null
                            : () => controller.loadTwins(keepSelection: true),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Atualizar'),
                      ),
                    ],
                  ),
                  if (controller.error != null) ...[
                    const SizedBox(height: 12),
                    Material(
                      color: const Color(0xFF7F1D1D),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFFECACA)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                controller.error!,
                                style: const TextStyle(color: Color(0xFFFEE2E2)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Expanded(
                    child: controller.selectedTwin == null
                        ? const TwinsListScreen()
                        : const TwinDetailScreen(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
