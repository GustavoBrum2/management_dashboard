import '../../models/compatibility.dart';
import '../../models/parts.dart';
import '../../models/pc_build.dart';

CompatibilityResult checkHddCompatibility(PcBuild build, Hdd hdd) {
  final result = CompatibilityResult.empty('hdd', hdd.name);
  final motherboard = build.motherboard;

  if (motherboard == null) {
    result.summary = 'Não é possível analisar HD SATA sem uma placa-mãe cadastrada na build.';
    result.status = CompatibilityStatus.insufficientData;
    return result;
  }

  if (motherboard.sataConnectors <= 0) {
    result.addBlocker('sata', 'A placa-mãe cadastrada não possui conectores SATA informados.');
  } else {
    final usedSata = build.storage.where((item) => storageInterfaceOf(item) == 'SATA').length;
    if (usedSata >= motherboard.sataConnectors) {
      result.addWarning(
        'sata',
        'Todos os ${motherboard.sataConnectors} conector(es) SATA parecem ocupados. Pode ser necessário substituir/remover um disco atual.',
      );
    } else {
      result.addReason(
        'sata',
        'Há ${motherboard.sataConnectors - usedSata} conector(es) SATA livre(s) para adicionar o HD.',
      );
    }
  }

  final pcCase = build.pcCase;
  if (pcCase != null) {
    final hasBay = hdd.formFactor == '3.5"' ? pcCase.driveBays35 > 0 : pcCase.driveBays25 > 0;
    if (!hasBay) {
      result.addWarning(
        'bay',
        'Gabinete cadastrado não informa baia livre/compatível para HD ${hdd.formFactor}.',
      );
    } else {
      result.addReason('bay', 'Gabinete possui baia compatível com HD ${hdd.formFactor}.');
    }
  } else {
    result.addWarning(
      'case',
      'Gabinete não cadastrado. Não foi possível validar baia física para o HD.',
    );
  }

  result.status = result.resolveStatus();
  result.summary = switch (result.status) {
    CompatibilityStatus.compatible => 'O HD SATA é compatível com sua build atual.',
    CompatibilityStatus.incompatible => 'O HD SATA não é compatível com sua build atual.',
    CompatibilityStatus.compatibleWithWarnings =>
      'O HD SATA pode funcionar, mas exige validação de portas/baia física.',
    CompatibilityStatus.insufficientData => 'Dados insuficientes para concluir a análise do HD.',
  };
  return result;
}
