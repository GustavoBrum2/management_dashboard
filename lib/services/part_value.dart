import '../models/digital_twin.dart';
import '../models/parts.dart';
import '../models/pc_build.dart';

class ScoredPart {
  const ScoredPart({
    required this.recommendation,
    required this.cost,
    required this.performance,
    required this.family,
  });

  final MvpRecommendation recommendation;
  final double cost;
  final double performance;
  final String family;

  double get valueRatio => performance / (cost <= 0 ? 1 : cost);
}

double estimatedCostOf(Part part) {
  return switch (part) {
    Ram() => _ramCost(part),
    Ssd() => _ssdCost(part),
    Gpu() => _gpuCost(part),
    _ => 1,
  };
}

double performanceOf(Part part) {
  return switch (part) {
    Ram() => _ramPerformance(part),
    Ssd() => _ssdPerformance(part),
    Gpu() => _gpuPerformance(part),
    _ => 1,
  };
}

String familyKeyOf(Part part) {
  return switch (part) {
    Ram() => 'ram-${part.type}-${part.capacityGb}-${part.speedMhz}',
    Ssd() => 'ssd-${part.interfaceType}-${part.capacityGb}-${part.pcieGeneration ?? 0}',
    Gpu() => _gpuFamily(part.name),
    _ => part.id,
  };
}

List<MvpRecommendation> pickTieredRecommendations(
  List<MvpRecommendation> compatible, {
  PcBuild? build,
}) {
  if (compatible.isEmpty) return const [];

  final scored = compatible
      .map(
        (item) => ScoredPart(
          recommendation: item,
          cost: estimatedCostOf(item.part),
          performance: performanceOf(item.part),
          family: familyKeyOf(item.part),
        ),
      )
      .toList();

  var unique = _dedupeFamilies(scored);
  final upgrades = unique.where((item) => _isUpgrade(item.recommendation.part, build)).toList();
  if (upgrades.length >= 2) {
    unique = upgrades;
  }

  unique.sort((a, b) => a.cost.compareTo(b.cost));

  if (unique.length == 1) {
    return [_withTier(unique.first, RecommendationTier.value)];
  }
  if (unique.length == 2) {
    return [
      _withTier(unique.first, RecommendationTier.economy),
      _withTier(unique.last, RecommendationTier.premium),
    ];
  }

  final economy = unique.first;
  final premium = unique.last;
  final middle = unique.sublist(1, unique.length - 1);
  middle.sort((a, b) {
    final valueCmp = b.valueRatio.compareTo(a.valueRatio);
    if (valueCmp != 0) return valueCmp;
    return a.cost.compareTo(b.cost);
  });
  final value = middle.first;

  return [
    _withTier(economy, RecommendationTier.economy),
    _withTier(value, RecommendationTier.value),
    _withTier(premium, RecommendationTier.premium),
  ];
}

MvpRecommendation _withTier(ScoredPart item, RecommendationTier tier) {
  return item.recommendation.copyWith(
    tier: tier,
    estimatedCost: item.cost,
    performanceIndex: item.performance,
  );
}

List<ScoredPart> _dedupeFamilies(List<ScoredPart> items) {
  final bestByFamily = <String, ScoredPart>{};
  for (final item in items) {
    final current = bestByFamily[item.family];
    if (current == null) {
      bestByFamily[item.family] = item;
      continue;
    }
    final scoreCmp = item.recommendation.score.compareTo(current.recommendation.score);
    if (scoreCmp > 0 || (scoreCmp == 0 && item.cost < current.cost)) {
      bestByFamily[item.family] = item;
    }
  }
  return bestByFamily.values.toList();
}

bool _isUpgrade(Part part, PcBuild? build) {
  if (build == null) return true;
  if (part is Ram) {
    final currentCapacity = build.totalRamGb;
    final currentSpeed = build.ram.fold<int>(0, (max, ram) => ram.speedMhz > max ? ram.speedMhz : max);
    return part.capacityGb > currentCapacity ||
        (part.capacityGb >= currentCapacity && part.speedMhz >= currentSpeed);
  }
  if (part is Ssd) {
    final currentCapacity = build.storage.fold<int>(0, (max, item) {
      final capacity = storageCapacityOf(item);
      return capacity > max ? capacity : max;
    });
    final hasNvme = build.storage.any((item) => item is Ssd && item.interfaceType == 'NVMe');
    if (part.interfaceType == 'NVMe' && !hasNvme) return true;
    return part.capacityGb > currentCapacity;
  }
  if (part is Gpu) {
    final current = build.gpu.isEmpty
        ? null
        : build.gpu.reduce((a, b) => performanceOf(a) >= performanceOf(b) ? a : b);
    if (current == null) return true;
    return performanceOf(part) > performanceOf(current) || part.vramGb > current.vramGb;
  }
  return true;
}

double _ramPerformance(Ram ram) => ram.capacityGb * 2 + ram.speedMhz / 200;

double _ramCost(Ram ram) {
  var cost = ram.capacityGb * 2.4 + ram.speedMhz / 160;
  final name = ram.name.toLowerCase();
  if (name.contains('rgb') || name.contains('royal') || name.contains('xtreem')) cost *= 1.18;
  return cost;
}

double _ssdPerformance(Ssd ssd) {
  var performance = ssd.capacityGb / 40;
  if (ssd.interfaceType.toLowerCase().contains('nvme')) performance += 18;
  performance += (ssd.pcieGeneration ?? 3) * 8;
  performance += (ssd.readSpeedMbps ?? 0) / 400;
  return performance;
}

double _ssdCost(Ssd ssd) {
  var cost = ssd.capacityGb / 32;
  if (ssd.interfaceType.toLowerCase().contains('nvme')) cost += 14;
  cost += (ssd.pcieGeneration ?? 3) * 10;
  final name = ssd.name.toLowerCase();
  if (name.contains('heatsink') || name.contains(' hs ') || name.contains('pro')) cost *= 1.12;
  return cost;
}

double _gpuPerformance(Gpu gpu) {
  return _gpuChipScore(gpu.name) + gpu.vramGb * 6 + gpu.tdp * 0.25 + gpu.pcieGeneration * 4;
}

double _gpuCost(Gpu gpu) {
  var cost = _gpuChipScore(gpu.name) + gpu.vramGb * 8 + gpu.tdp * 0.35;
  final name = gpu.name.toLowerCase();
  if (name.contains('rog') ||
      name.contains('strix') ||
      name.contains('aorus') ||
      name.contains('suprim') ||
      name.contains('liquid')) {
    cost *= 1.22;
  }
  return cost;
}

double _gpuChipScore(String name) {
  final lower = name.toLowerCase();
  final nvidia = RegExp(r'(?:rtx|gtx)\s*(\d{3,4})(?:\s*(ti|super))?').firstMatch(lower);
  if (nvidia != null) {
    final model = int.tryParse(nvidia.group(1) ?? '') ?? 0;
    var score = _numericChipScore(model);
    final suffix = nvidia.group(2);
    if (suffix == 'ti') score += 8;
    if (suffix == 'super') score += 6;
    return score;
  }

  final amd = RegExp(r'rx\s*(\d{3,4})(?:\s*(xtx|xt))?').firstMatch(lower);
  if (amd != null) {
    final model = int.tryParse(amd.group(1) ?? '') ?? 0;
    var score = _numericChipScore(model) * 0.92;
    final suffix = amd.group(2);
    if (suffix == 'xtx') score += 10;
    if (suffix == 'xt') score += 6;
    return score;
  }

  final intel = RegExp(r'arc\s*[ab]?(\d{3})').firstMatch(lower);
  if (intel != null) {
    final model = int.tryParse(intel.group(1) ?? '') ?? 0;
    return _numericChipScore(model) * 0.7;
  }

  return 40;
}

double _numericChipScore(int model) {
  if (model >= 1000) {
    final series = model ~/ 100;
    final tier = model % 100;
    return series * 18 + tier * 0.9;
  }
  return model * 0.35;
}

String _gpuFamily(String name) {
  final lower = name.toLowerCase();
  final nvidia = RegExp(r'(rtx|gtx)\s*(\d{3,4})(?:\s*(ti|super))?').firstMatch(lower);
  if (nvidia != null) {
    return '${nvidia.group(1)}-${nvidia.group(2)}-${nvidia.group(3) ?? ''}';
  }
  final amd = RegExp(r'rx\s*(\d{3,4})(?:\s*(xtx|xt))?').firstMatch(lower);
  if (amd != null) {
    return 'rx-${amd.group(1)}-${amd.group(2) ?? ''}';
  }
  return lower.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
}
