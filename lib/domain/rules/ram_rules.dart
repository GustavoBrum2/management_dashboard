import '../../models/compatibility.dart';
import '../../models/parts.dart';
import '../../models/pc_build.dart';

CompatibilityResult checkRamCompatibility(PcBuild build, Ram ram) {
  final result = CompatibilityResult.empty('ram', ram.name);
  final motherboard = build.motherboard;

  if (motherboard == null) {
    result.summary = 'Não é possível analisar sem uma placa-mãe cadastrada na build.';
    result.status = CompatibilityStatus.insufficientData;
    return result;
  }

  _checkRamType(motherboard.ramType, ram, result);
  _checkRamCapacity(motherboard.maxRamCapacity, motherboard.ramSlots, ram, build.ram, result);
  _checkRamSpeed(motherboard.maxRamSpeed, ram, result);
  _checkRamSlots(motherboard.ramSlots, ram, build.ram, result);

  result.status = result.resolveStatus();
  result.summary = _summary(result.status);
  return result;
}

void _checkRamType(String boardRamType, Ram ram, CompatibilityResult result) {
  if (ram.type != boardRamType) {
    result.addBlocker(
      'ram_type',
      'A memória é ${ram.type}, mas a placa-mãe suporta apenas $boardRamType. São fisicamente incompatíveis.',
    );
  } else {
    result.addReason('ram_type', 'Tipo de memória ${ram.type} compatível com a placa-mãe.');
  }
}

void _checkRamCapacity(
  int maxCapacity,
  int totalSlots,
  Ram ram,
  List<Ram> existingRam,
  CompatibilityResult result,
) {
  final existingTotal = existingRam.fold(0, (sum, item) => sum + item.capacityGb);
  final newTotalIfAdded = existingTotal + ram.capacityGb;
  final capacityPerModule = ram.modules > 0 ? ram.capacityGb / ram.modules : ram.capacityGb.toDouble();

  if (maxCapacity <= 0) {
    result.addWarning(
      'capacity',
      'A placa-mãe cadastrada não possui limite máximo de RAM informado na base. A capacidade não foi usada como critério bloqueante.',
    );
    return;
  }

  if (ram.capacityGb > maxCapacity) {
    result.addBlocker(
      'capacity',
      'O kit possui ${ram.capacityGb}GB, acima do limite de ${maxCapacity}GB da placa-mãe.',
    );
  } else if (newTotalIfAdded > maxCapacity) {
    result.addWarning(
      'capacity',
      'Se esse kit for somado à RAM atual, a capacidade chegaria a ${newTotalIfAdded}GB, acima do limite de ${maxCapacity}GB. Pode ser necessário substituir os módulos atuais em vez de adicionar.',
    );
    result.addReason(
      'capacity',
      'O kit de ${ram.capacityGb}GB, isoladamente, está dentro do limite de ${maxCapacity}GB da placa-mãe.',
    );
  } else {
    result.addReason(
      'capacity',
      'Capacidade estimada de ${newTotalIfAdded}GB dentro do limite de ${maxCapacity}GB da placa-mãe.',
    );
  }

  if (totalSlots > 0) {
    final maxPerSlot = maxCapacity / totalSlots;
    if (capacityPerModule > maxPerSlot) {
      result.addWarning(
        'capacity',
        'Cada módulo parece ter ${capacityPerModule.round()}GB, mas o máximo estimado por slot é ${maxPerSlot.round()}GB. Confirme no manual da placa-mãe.',
      );
    }
  }
}

void _checkRamSpeed(int maxSpeed, Ram ram, CompatibilityResult result) {
  if (maxSpeed <= 0) {
    result.addWarning(
      'speed',
      'A placa-mãe cadastrada não possui velocidade máxima de RAM informada na base. A frequência não foi usada como critério bloqueante.',
    );
    return;
  }

  if (ram.speedMhz > maxSpeed) {
    result.addWarning(
      'speed',
      'A memória opera a ${ram.speedMhz}MHz, mas a placa-mãe suporta até ${maxSpeed}MHz. Funcionará, mas limitada à velocidade máxima da placa.',
    );
    result.recommendations.add(
      'Considere uma memória de até ${maxSpeed}MHz para não pagar a mais por velocidade que não será aproveitada.',
    );
  } else {
    result.addReason('speed', 'Velocidade de ${ram.speedMhz}MHz suportada pela placa-mãe.');
  }
}

void _checkRamSlots(int totalSlots, Ram ram, List<Ram> existingRam, CompatibilityResult result) {
  if (totalSlots <= 0) {
    result.addWarning(
      'slots',
      'A placa-mãe cadastrada não possui quantidade de slots de RAM informada na base.',
    );
    return;
  }

  final usedSlots = existingRam.fold(0, (sum, item) => sum + item.modules);
  final neededSlotsIfAdded = usedSlots + ram.modules;

  if (ram.modules > totalSlots) {
    result.addBlocker(
      'slots',
      'O kit precisa de ${ram.modules} slot(s), mas a placa-mãe possui apenas $totalSlots.',
    );
  } else if (neededSlotsIfAdded > totalSlots) {
    result.addWarning(
      'slots',
      'Se esse kit for somado à RAM atual, seriam usados $neededSlotsIfAdded slots, mas a placa-mãe possui $totalSlots. Pode ser necessário substituir módulos atuais em vez de adicionar.',
    );
    result.addReason(
      'slots',
      'O kit precisa de ${ram.modules} slot(s), quantidade suportada pela placa-mãe.',
    );
  } else {
    result.addReason(
      'slots',
      '${totalSlots - usedSlots} slot(s) livre(s) disponível(is) para ${ram.modules} módulo(s).',
    );
  }

  if (existingRam.isNotEmpty) {
    final existing = existingRam.first;
    if (ram.type == existing.type && ram.speedMhz != existing.speedMhz) {
      result.addWarning(
        'mixed_speed',
        'Misturar módulos de velocidades diferentes (${ram.speedMhz}MHz com ${existing.speedMhz}MHz) fará todos operarem na menor velocidade.',
      );
    }
  }
}

String _summary(CompatibilityStatus status) {
  return switch (status) {
    CompatibilityStatus.compatible => 'A memória RAM é totalmente compatível com sua build atual.',
    CompatibilityStatus.incompatible => 'A memória RAM não é compatível com sua build atual.',
    CompatibilityStatus.compatibleWithWarnings => 'A memória RAM funciona no seu PC, mas com limitações.',
    CompatibilityStatus.insufficientData => 'Dados insuficientes para concluir a análise.',
  };
}
