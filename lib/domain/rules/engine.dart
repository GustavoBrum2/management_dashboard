import '../../models/compatibility.dart';
import '../../models/parts.dart';
import '../../models/pc_build.dart';
import 'cpu_rules.dart';
import 'gpu_rules.dart';
import 'hdd_rules.dart';
import 'motherboard_rules.dart';
import 'ram_rules.dart';
import 'ssd_rules.dart';

CompatibilityResult analyzeCompatibility(PcBuild build, Part part) {
  return switch (part) {
    Cpu() => checkCpuCompatibility(build, part),
    Motherboard() => checkMotherboardCompatibility(build, part),
    Ram() => checkRamCompatibility(build, part),
    Gpu() => checkGpuCompatibility(build, part),
    Ssd() => checkSsdCompatibility(build, part),
    Hdd() => checkHddCompatibility(build, part),
    _ => CompatibilityResult(
        status: CompatibilityStatus.insufficientData,
        partCategory: part.category,
        partName: part.name,
        summary: 'Análise de compatibilidade para ${part.category} ainda não implementada.',
        blockers: [],
        warnings: [],
        reasons: [],
        recommendations: [],
        analyzedAt: DateTime.now().toIso8601String(),
      ),
  };
}
