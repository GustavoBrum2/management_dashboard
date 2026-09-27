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

    await tester.tap(find.text('Notebook de Teste'));
    await tester.pumpAndSettle();

    expect(find.text('Recomendações de upgrade'), findsOneWidget);

    await tester.tap(find.text('Gerar recomendações'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Corsair Vengeance'), findsOneWidget);
    expect(find.text('Custo-benefício'), findsOneWidget);
    expect(find.text('Compatível'), findsWidgets);

    await tester.ensureVisible(find.text('Simular upgrade'));
    await tester.tap(find.text('Simular upgrade'));
    await tester.pumpAndSettle();

    expect(find.text('Simulação'), findsWidgets);
    expect(find.text('Simulando'), findsOneWidget);
    expect(find.textContaining('Peça atual:'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar à frota'));
    await tester.pumpAndSettle();

    expect(find.text('Frota de Digital Twins'), findsOneWidget);
    expect(find.text('Simulação'), findsWidgets);
    expect(find.textContaining('Corsair Vengeance'), findsWidgets);
    expect(find.textContaining('Atual:'), findsOneWidget);

    await tester.tap(find.text('Notebook de Teste'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Remover'));
    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle();

    expect(find.text('Simulação'), findsNothing);
    await tester.ensureVisible(find.text('Simular upgrade'));
    expect(find.text('Simular upgrade'), findsOneWidget);
  });
}
