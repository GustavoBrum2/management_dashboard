import '../../models/compatibility.dart';
import '../../models/parts.dart';
import '../../models/pc_build.dart';

CompatibilityResult checkCpuCompatibility(PcBuild build, Cpu cpu) {
  final result = CompatibilityResult.empty('cpu', cpu.name);
  final motherboard = build.motherboard;

  if (motherboard == null) {
    result.summary = 'Não é possível analisar o processador sem uma placa-mãe cadastrada na build.';
    result.status = CompatibilityStatus.insufficientData;
    return result;
  }

  if (cpu.socket != motherboard.socket) {
    result.addBlocker(
      'socket',
      'O processador usa socket ${cpu.socket}, mas a placa-mãe cadastrada usa socket ${motherboard.socket}.',
    );
  } else {
    result.addReason(
      'socket',
      'Socket ${cpu.socket} compatível com a placa-mãe cadastrada.',
    );
  }

  if (cpu.chipsets.isNotEmpty) {
    final normalizedBoardChipset = motherboard.chipset.toLowerCase();
    final supported = cpu.chipsets.any((chipset) => chipset.toLowerCase() == normalizedBoardChipset);

    if (supported) {
      result.addReason(
        'chipset',
        'Chipset ${motherboard.chipset} aparece como suportado para esse processador na base local.',
      );
    } else {
      result.addWarning(
        'chipset',
        'O socket é compatível, mas o chipset ${motherboard.chipset} não apareceu na lista de chipsets desse processador na base local. Pode exigir validação de BIOS/lista de suporte da fabricante.',
      );
    }
  }

  final cooler = build.cooler;
  if (cooler == null) {
    result.addWarning(
      'cooler',
      'Cooler não cadastrado. Não foi possível validar dissipação térmica para o TDP do processador.',
    );
  } else if (cooler.supportedSockets.isNotEmpty && !cooler.supportedSockets.contains(cpu.socket)) {
    result.addBlocker(
      'cooler_socket',
      'O cooler cadastrado não informa suporte ao socket ${cpu.socket}.',
    );
  } else if (cooler.tdpRating != null && cooler.tdpRating! < cpu.tdp) {
    result.addWarning(
      'cooler_tdp',
      'O processador tem TDP de ${cpu.tdp}W e o cooler cadastrado é indicado para ${cooler.tdpRating}W.',
    );
  }

  result.status = result.resolveStatus();
  result.summary = switch (result.status) {
    CompatibilityStatus.compatible => 'O processador é compatível com a placa-mãe cadastrada.',
    CompatibilityStatus.incompatible => 'O processador não é compatível com a build atual.',
    CompatibilityStatus.compatibleWithWarnings =>
      'O processador parece compatível, mas exige algumas validações adicionais.',
    CompatibilityStatus.insufficientData => 'Dados insuficientes para concluir a análise do processador.',
  };
  return result;
}
