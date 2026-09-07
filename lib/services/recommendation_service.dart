import '../data/parts_repository.dart';
import '../domain/rules/engine.dart';
import '../models/compatibility.dart';
import '../models/digital_twin.dart';
import '../models/parts.dart';
import '../models/pc_build.dart';

class RecommendationService {
  RecommendationService(this._repository);

  final PartsRepository _repository;

  Future<List<MvpRecommendation>> recommend(
    PcBuild build,
    RecommendationCategory category, {
    int limit = 5,
  }) async {
    final parts = await _parts(category);
    final scored = <MvpRecommendation>[];

    for (final part in parts) {
      final result = analyzeCompatibility(build, part);
      if (result.status == CompatibilityStatus.compatible ||
          result.status == CompatibilityStatus.compatibleWithWarnings) {
        scored.add(
          MvpRecommendation(
            part: part,
            result: result,
            score: _score(part, result),
          ),
        );
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    if (scored.length <= limit) return scored;
    return scored.sublist(0, limit);
  }

  Future<List<Part>> _parts(RecommendationCategory category) async {
    return switch (category) {
      RecommendationCategory.ram => await _repository.getRam(),
      RecommendationCategory.ssd => await _repository.getSsds(),
      RecommendationCategory.gpu => await _repository.getGpus(),
    };
  }

  double _score(Part part, CompatibilityResult result) {
    var score = result.status == CompatibilityStatus.compatible ? 100.0 : 70.0;
    score += result.reasons.length * 3;
    score -= result.warnings.length * 8;
    score -= result.blockers.length * 50;

    if (part is Ram) {
      score += (part.capacityGb.clamp(0, 64)) / 2;
    }
    if (part is Ssd) {
      score += (part.capacityGb.clamp(0, 4096)) / 256;
      if (part.interfaceType.toLowerCase().contains('nvme')) score += 8;
    }

    return score;
  }
}
