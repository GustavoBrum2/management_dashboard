import 'package:flutter_test/flutter_test.dart';
import 'package:management_dashboard/domain/rules/engine.dart';
import 'package:management_dashboard/models/compatibility.dart';
import 'package:management_dashboard/models/digital_twin.dart';
import 'package:management_dashboard/services/recommendation_service.dart';

import 'helpers/fakes.dart';

void main() {
  test('RAM DDR5 compatível entra no ranking e DDR4 é bloqueada', () async {
    final twin = sampleTwin();
    final service = RecommendationService(
      FakePartsRepository(
        ram: [sampleCompatibleRam(), sampleIncompatibleRam()],
      ),
    );

    final results = await service.recommend(twin.build, RecommendationCategory.ram);

    expect(results, hasLength(1));
    expect(results.first.part.name, contains('Corsair'));
    expect(results.first.result.status, isNot(CompatibilityStatus.incompatible));
  });

  test('engine marca DDR4 como incompatível em placa DDR5', () {
    final result = analyzeCompatibility(sampleTwin().build, sampleIncompatibleRam());
    expect(result.status, CompatibilityStatus.incompatible);
    expect(result.blockers, isNotEmpty);
  });
}
