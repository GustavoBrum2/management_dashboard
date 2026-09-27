import 'digital_twin.dart';
import 'parts.dart';
import 'pc_build.dart';

class UpgradeSimulation {
  const UpgradeSimulation({
    this.ram,
    this.gpu,
    this.ssd,
  });

  final Ram? ram;
  final Gpu? gpu;
  final Ssd? ssd;

  bool get isEmpty => ram == null && gpu == null && ssd == null;

  bool get isNotEmpty => !isEmpty;

  Part? partFor(RecommendationCategory category) {
    return switch (category) {
      RecommendationCategory.ram => ram,
      RecommendationCategory.gpu => gpu,
      RecommendationCategory.ssd => ssd,
    };
  }

  bool contains(Part part) {
    return ram?.id == part.id || gpu?.id == part.id || ssd?.id == part.id;
  }

  UpgradeSimulation withPart(Part part) {
    return switch (part) {
      Ram() => UpgradeSimulation(ram: part, gpu: gpu, ssd: ssd),
      Gpu() => UpgradeSimulation(ram: ram, gpu: part, ssd: ssd),
      Ssd() => UpgradeSimulation(ram: ram, gpu: gpu, ssd: part),
      _ => this,
    };
  }

  UpgradeSimulation without(RecommendationCategory category) {
    return switch (category) {
      RecommendationCategory.ram => UpgradeSimulation(ram: null, gpu: gpu, ssd: ssd),
      RecommendationCategory.gpu => UpgradeSimulation(ram: ram, gpu: null, ssd: ssd),
      RecommendationCategory.ssd => UpgradeSimulation(ram: ram, gpu: gpu, ssd: null),
    };
  }
}

PcBuild applySimulation(PcBuild original, UpgradeSimulation simulation) {
  if (simulation.isEmpty) return original;

  return original.copyWith(
    ram: simulation.ram != null ? [simulation.ram!] : original.ram,
    gpu: simulation.gpu != null ? _gpusWithSimulation(original.gpu, simulation.gpu!) : original.gpu,
    storage: simulation.ssd != null
        ? _storageWithSimulation(original.storage, simulation.ssd!)
        : original.storage,
  );
}

List<Gpu> _gpusWithSimulation(List<Gpu> current, Gpu simulated) {
  final integrated = current.where(_looksIntegrated).toList();
  return [simulated, ...integrated];
}

bool _looksIntegrated(Gpu gpu) {
  final name = gpu.name.toLowerCase();
  return gpu.vramGb <= 0 ||
      name.contains('uhd') ||
      name.contains('iris') ||
      name.contains('vega') ||
      name.contains('graphics') && !name.contains('geforce') && !name.contains('radeon rx');
}

List<Part> _storageWithSimulation(List<Part> current, Ssd simulated) {
  final withoutSameRole = current.where((item) {
    if (item is Ssd) return item.id != simulated.id;
    return true;
  }).toList();
  return [simulated, ...withoutSameRole];
}
