import '../../models/compatibility.dart';
import '../../models/parts.dart';
import '../../models/pc_build.dart';

CompatibilityResult checkSsdCompatibility(PcBuild build, Ssd ssd) {
  final result = CompatibilityResult.empty('ssd', ssd.name);
  final motherboard = build.motherboard;

  if (motherboard == null) {
    result.summary = 'Não é possível analisar sem uma placa-mãe cadastrada na build.';
    result.status = CompatibilityStatus.insufficientData;
    return result;
  }

  if (ssd.interfaceType == 'SATA' && ssd.formFactor == '2.5"') {
    _checkSataSsd(motherboard.sataConnectors, build.storage.length, result);
  } else if (ssd.formFactor.startsWith('M.2')) {
    _checkM2Ssd(motherboard.m2Slots, ssd, result);
  }

  result.status = result.resolveStatus();
  result.summary = _summary(result.status);
  return result;
}

void _checkSataSsd(int sataConnectors, int currentStorageCount, CompatibilityResult result) {
  if (sataConnectors == 0) {
    result.addBlocker('interface', 'A placa-mãe não possui conectores SATA.');
    return;
  }

  if (currentStorageCount >= sataConnectors) {
    result.addWarning(
      'slots',
      'Todos os conectores SATA já estão ocupados. Será necessário remover um dispositivo.',
    );
  } else {
    result.addReason('interface', 'Conector SATA disponível na placa-mãe.');
  }

  result.addReason(
    'physical',
    'SSD 2.5" é compatível com qualquer gabinete que tenha baia de 2.5".',
  );
}

void _checkM2Ssd(List<M2Slot> m2Slots, Ssd ssd, CompatibilityResult result) {
  if (m2Slots.isEmpty) {
    result.addBlocker('interface', 'A placa-mãe não possui slots M.2.');
    return;
  }

  final compatibleSlots = m2Slots.where((slot) {
    final formFactorOk = slot.formFactors.contains(ssd.formFactor);
    final interfaceOk = ssd.interfaceType == 'NVMe' ? slot.supportsNvme : slot.supportsSata;
    return formFactorOk && interfaceOk;
  }).toList();

  if (compatibleSlots.isEmpty) {
    if (ssd.interfaceType == 'NVMe' && m2Slots.every((slot) => !slot.supportsNvme)) {
      result.addBlocker(
        'interface',
        'Nenhum slot M.2 da placa-mãe suporta NVMe. O SSD não funcionará.',
      );
    } else if (!m2Slots.any((slot) => slot.formFactors.contains(ssd.formFactor))) {
      result.addBlocker('physical', 'Nenhum slot M.2 suporta o formato ${ssd.formFactor}.');
    } else {
      result.addBlocker(
        'interface',
        'Nenhum slot M.2 é compatível com a combinação de interface e formato deste SSD.',
      );
    }
    return;
  }

  result.addReason('interface', '${compatibleSlots.length} slot(s) M.2 compatível(is) encontrado(s).');
  result.addReason('physical', 'Formato ${ssd.formFactor} suportado.');

  if (ssd.interfaceType == 'NVMe' && ssd.pcieGeneration != null) {
    _checkPcieGeneration(compatibleSlots, ssd, result);
  }
}

void _checkPcieGeneration(List<M2Slot> slots, Ssd ssd, CompatibilityResult result) {
  final bestSlotGen = slots.map((slot) => slot.pcieGeneration).reduce((a, b) => a > b ? a : b);

  if (ssd.pcieGeneration != null && bestSlotGen < ssd.pcieGeneration!) {
    result.addWarning(
      'bandwidth',
      'O SSD é PCIe ${ssd.pcieGeneration}.0, mas o melhor slot disponível opera em PCIe $bestSlotGen.0. O SSD funcionará, mas com velocidade reduzida.',
    );
    result.recommendations.add(
      'Considere um SSD PCIe $bestSlotGen.0 de menor custo, pois o ganho prático pode ser mais coerente com seu setup atual.',
    );
  } else {
    result.addReason('bandwidth', 'Interface PCIe $bestSlotGen.0 compatível — desempenho total disponível.');
  }
}

String _summary(CompatibilityStatus status) {
  return switch (status) {
    CompatibilityStatus.compatible => 'O SSD é totalmente compatível com sua build atual.',
    CompatibilityStatus.incompatible => 'O SSD não é compatível com sua build atual.',
    CompatibilityStatus.compatibleWithWarnings =>
      'O SSD funciona no seu PC, mas com limitações importantes.',
    CompatibilityStatus.insufficientData => 'Dados insuficientes para concluir a análise.',
  };
}
