import 'package:flutter/material.dart';

import '../state/dashboard_scope.dart';
import '../widgets/stat_card.dart';
import '../widgets/twin_card.dart';

class TwinsListScreen extends StatefulWidget {
  const TwinsListScreen({super.key});

  @override
  State<TwinsListScreen> createState() => _TwinsListScreenState();
}

class _TwinsListScreenState extends State<TwinsListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = DashboardScope.of(context);
    final twins = controller.filteredTwins;
    final identifiedCpu = controller.twins.where((twin) => twin.build.cpu != null).length;
    final identifiedRam = controller.twins.where((twin) => twin.build.ram.isNotEmpty).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frota de Digital Twins',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Máquinas registradas pelo agente local e sincronizadas no Firebase.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 1100 ? 3 : constraints.maxWidth >= 720 ? 2 : 1;
            return Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Twins ativos',
                    value: '${controller.twins.length}',
                    icon: Icons.devices_other,
                  ),
                ),
                if (columns > 1) const SizedBox(width: 12),
                if (columns > 1)
                  Expanded(
                    child: StatCard(
                      label: 'CPU identificada',
                      value: '$identifiedCpu',
                      icon: Icons.memory,
                    ),
                  ),
                if (columns > 2) const SizedBox(width: 12),
                if (columns > 2)
                  Expanded(
                    child: StatCard(
                      label: 'RAM identificada',
                      value: '$identifiedRam',
                      icon: Icons.sd_storage_outlined,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          onChanged: controller.setSearchQuery,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Buscar por nome, CPU, GPU ou ID',
          ),
        ),
        const SizedBox(height: 16),
        if (controller.loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (twins.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                controller.twins.isEmpty
                    ? 'Nenhum Digital Twin encontrado no Firebase.'
                    : 'Nenhum resultado para essa busca.',
              ),
            ),
          )
        else
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 1280
                    ? 3
                    : constraints.maxWidth >= 840
                        ? 2
                        : 1;
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: crossAxisCount == 1 ? 1.7 : 1.15,
                  ),
                  itemCount: twins.length,
                  itemBuilder: (context, index) {
                    final twin = twins[index];
                    return TwinCard(
                      twin: twin,
                      onOpen: () => controller.selectTwin(twin),
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
