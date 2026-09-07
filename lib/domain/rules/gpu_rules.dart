import '../../models/compatibility.dart';
import '../../models/parts.dart';
import '../../models/pc_build.dart';

CompatibilityResult checkGpuCompatibility(PcBuild build, Gpu gpu) {
  final result = CompatibilityResult.empty('gpu', gpu.name);
  final motherboard = build.motherboard;

  if (motherboard == null) {
    result.summary = 'Não é possível analisar sem uma placa-mãe cadastrada na build.';
    result.status = CompatibilityStatus.insufficientData;
    return result;
  }

  _checkPcieSlot(motherboard.pcieSlots, gpu, result);
  _checkPhysicalFit(build, gpu, result);
  _checkPowerRequirements(build, gpu, result);

  result.status = result.resolveStatus();
  result.summary = _summary(result.status);
  return result;
}

void _checkPcieSlot(List<PcieSlot> pcieSlots, Gpu gpu, CompatibilityResult result) {
  final x16Slots = pcieSlots.where((slot) => slot.physicalSize == 'x16').toList();

  if (x16Slots.isEmpty) {
    result.addBlocker('pcie', 'A placa-mãe não possui slot PCIe x16 para a GPU.');
    return;
  }

  result.addReason('pcie', 'Slot PCIe x16 disponível na placa-mãe.');

  final bestGen = x16Slots.map((slot) => slot.generation).reduce((a, b) => a > b ? a : b);
  if (bestGen < gpu.pcieGeneration) {
    result.addWarning(
      'pcie_bandwidth',
      'A GPU usa PCIe ${gpu.pcieGeneration}.0, mas o melhor slot disponível é PCIe $bestGen.0. Pode haver perda marginal de desempenho.',
    );
  }
}

void _checkPhysicalFit(PcBuild build, Gpu gpu, CompatibilityResult result) {
  final pcCase = build.pcCase;
  if (pcCase == null) {
    result.addWarning(
      'physical',
      'Gabinete não cadastrado. Não é possível verificar se a GPU cabe fisicamente.',
    );
    return;
  }

  if (gpu.lengthMm > pcCase.maxGpuLengthMm) {
    result.addBlocker(
      'physical',
      'A GPU tem ${gpu.lengthMm}mm, mas o gabinete suporta no máximo ${pcCase.maxGpuLengthMm}mm.',
    );
  } else {
    result.addReason(
      'physical',
      'GPU de ${gpu.lengthMm}mm cabe no gabinete (máx: ${pcCase.maxGpuLengthMm}mm).',
    );
  }
}

void _checkPowerRequirements(PcBuild build, Gpu gpu, CompatibilityResult result) {
  final psu = build.psu;
  if (psu == null) {
    result.addWarning(
      'power',
      'Fonte não cadastrada. Não é possível verificar se a alimentação é suficiente.',
    );
    return;
  }

  final estimatedSystemDraw = _estimateSystemPower(build);
  final totalRequired = estimatedSystemDraw + gpu.tdp;
  final margin = psu.wattage - totalRequired;

  if (margin < 0) {
    result.addBlocker(
      'power',
      'Consumo estimado de ${totalRequired}W excede a capacidade da fonte de ${psu.wattage}W.',
    );
    result.recommendations.add(
      'Considere uma fonte de pelo menos ${totalRequired + 100}W para manter margem de segurança.',
    );
  } else if (margin < 100) {
    result.addWarning(
      'power',
      'Consumo estimado de ${totalRequired}W deixa apenas ${margin}W de margem na fonte de ${psu.wattage}W. Recomenda-se pelo menos 100W de folga.',
    );
  } else {
    result.addReason(
      'power',
      'Fonte de ${psu.wattage}W comporta o consumo estimado de ${totalRequired}W com ${margin}W de margem.',
    );
  }

  final needed8pin = gpu.powerConnectors.where((connector) => connector.contains('8')).length;
  final needed6pin = gpu.powerConnectors
      .where((connector) => connector.contains('6') && !connector.contains('8'))
      .length;

  if (needed8pin > psu.connectors.pcie8pin) {
    result.addBlocker(
      'connectors',
      'A GPU requer $needed8pin conector(es) PCIe 8-pin, mas a fonte possui apenas ${psu.connectors.pcie8pin}.',
    );
  }

  if (needed6pin > psu.connectors.pcie6pin) {
    result.addWarning(
      'connectors',
      'A GPU requer $needed6pin conector(es) PCIe 6-pin, mas a fonte possui apenas ${psu.connectors.pcie6pin}.',
    );
  }
}

int _estimateSystemPower(PcBuild build) {
  var power = 50;
  if (build.cpu != null) power += build.cpu!.tdp;
  power += build.ram.length * 5;
  power += build.storage.length * 8;
  return power;
}

String _summary(CompatibilityStatus status) {
  return switch (status) {
    CompatibilityStatus.compatible => 'A GPU é totalmente compatível com sua build atual.',
    CompatibilityStatus.incompatible => 'A GPU não é compatível com sua build atual.',
    CompatibilityStatus.compatibleWithWarnings =>
      'A GPU funciona no seu PC, mas com ressalvas importantes.',
    CompatibilityStatus.insufficientData => 'Dados insuficientes para concluir a análise.',
  };
}
