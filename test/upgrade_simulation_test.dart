import 'package:flutter_test/flutter_test.dart';
import 'package:management_dashboard/models/digital_twin.dart';
import 'package:management_dashboard/models/upgrade_simulation.dart';
import 'package:management_dashboard/state/dashboard_controller.dart';

import 'helpers/fakes.dart';

void main() {
  test('simulação substitui a categoria sem alterar o build original', () {
    final original = sampleTwin().build;
    final simulation = const UpgradeSimulation().withPart(sampleCompatibleRam());
    final viewed = applySimulation(original, simulation);

    expect(original.ram.first.name, contains('Kingston 16GB'));
    expect(viewed.ram, hasLength(1));
    expect(viewed.ram.first.name, contains('Corsair'));
    expect(original.gpu, viewed.gpu);
  });

  test('trocar ou remover a simulação não apaga a peça atual', () {
    final original = sampleTwin().build;
    var simulation = const UpgradeSimulation().withPart(sampleCompatibleRam());
    simulation = simulation.withPart(samplePremiumRam());
    expect(simulation.ram?.name, contains('64GB'));
    expect(original.ram.first.name, contains('Kingston 16GB'));

    simulation = simulation.without(RecommendationCategory.ram);
    expect(simulation.ram, isNull);
    expect(applySimulation(original, simulation).ram.first.name, contains('Kingston 16GB'));
  });

  test('confirmar upgrade troca o build e guarda o anterior no histórico', () {
    final twin = sampleTwin();
    final simulation = const UpgradeSimulation().withPart(sampleCompatibleRam());
    final confirmedAt = DateTime.utc(2026, 10, 27, 12);
    final updated = applyConfirmedUpgrade(twin, simulation, confirmedAt: confirmedAt);

    expect(updated.build.ram.first.name, contains('Corsair'));
    expect(updated.current.source, 'upgrade');
    expect(updated.history, hasLength(1));
    expect(updated.history.first.build.ram.first.name, contains('Kingston 16GB'));
    expect(twin.build.ram.first.name, contains('Kingston 16GB'));
    expect(twin.hasUpgradeHistory, isFalse);
    expect(updated.hasUpgradeHistory, isTrue);
  });

  test('histórico permanece vazio enquanto o upgrade não for confirmado', () {
    final twin = sampleTwin();
    final simulation = const UpgradeSimulation().withPart(sampleCompatibleRam());

    expect(twin.hasUpgradeHistory, isFalse);
    expect(applySimulation(twin.build, simulation).ram.first.name, contains('Corsair'));
    expect(twin.history, isEmpty);
    expect(applyConfirmedUpgrade(twin, const UpgradeSimulation()).history, isEmpty);
  });

  test('controller confirma a simulação e mantém o histórico após recarregar', () async {
    final controller = DashboardController(
      twinsRepository: FakeTwinsRepository([sampleTwin()]),
      partsRepository: FakePartsRepository(ram: [sampleCompatibleRam()]),
    );

    await controller.loadTwins();
    controller.selectTwin(controller.twins.first);
    await controller.generateRecommendations();
    controller.simulateRecommendation(controller.recommendations.first);
    controller.confirmSimulation();

    expect(controller.selectedSimulation.isEmpty, isTrue);
    expect(controller.selectedTwin!.hasUpgradeHistory, isTrue);
    expect(controller.selectedTwin!.build.ram.first.name, contains('Corsair'));
    expect(controller.selectedTwin!.history.first.build.ram.first.name, contains('Kingston'));

    await controller.loadTwins(keepSelection: true);
    expect(controller.selectedTwin!.build.ram.first.name, contains('Corsair'));
    expect(controller.selectedTwin!.hasUpgradeHistory, isTrue);
  });
}
