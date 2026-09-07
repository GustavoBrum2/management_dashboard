import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:management_dashboard/main.dart';

import 'helpers/fakes.dart';

void main() {
  testWidgets('lista Digital Twins e abre recomendações', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ManagementDashboardApp(
        twinsRepository: FakeTwinsRepository([sampleTwin()]),
        partsRepository: FakePartsRepository(ram: [sampleCompatibleRam()]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Frota de Digital Twins'), findsOneWidget);
    expect(find.text('Notebook de Teste'), findsOneWidget);

    await tester.tap(find.text('Gerenciar'));
    await tester.pumpAndSettle();

    expect(find.text('Recomendações de upgrade'), findsOneWidget);

    await tester.tap(find.text('Gerar recomendações'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Corsair Vengeance'), findsOneWidget);
    expect(find.text('Compatível'), findsWidgets);
  });
}
