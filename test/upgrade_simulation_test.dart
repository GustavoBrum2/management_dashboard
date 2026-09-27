import 'package:flutter_test/flutter_test.dart';
import 'package:management_dashboard/models/digital_twin.dart';
import 'package:management_dashboard/models/upgrade_simulation.dart';

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
}
