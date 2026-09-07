enum CompatibilityStatus {
  compatible,
  incompatible,
  compatibleWithWarnings,
  insufficientData,
}

class CompatibilityReason {
  const CompatibilityReason({
    required this.dimension,
    required this.message,
    required this.severity,
  });

  final String dimension;
  final String message;
  final String severity;
}

class CompatibilityResult {
  CompatibilityResult({
    required this.status,
    required this.partCategory,
    required this.partName,
    required this.summary,
    required this.blockers,
    required this.warnings,
    required this.reasons,
    required this.recommendations,
    required this.analyzedAt,
  });

  CompatibilityStatus status;
  final String partCategory;
  final String partName;
  String summary;
  final List<CompatibilityReason> blockers;
  final List<CompatibilityReason> warnings;
  final List<CompatibilityReason> reasons;
  final List<String> recommendations;
  final String analyzedAt;

  factory CompatibilityResult.empty(String partCategory, String partName) {
    return CompatibilityResult(
      status: CompatibilityStatus.insufficientData,
      partCategory: partCategory,
      partName: partName,
      summary: '',
      blockers: [],
      warnings: [],
      reasons: [],
      recommendations: [],
      analyzedAt: DateTime.now().toIso8601String(),
    );
  }

  void addBlocker(String dimension, String message) {
    blockers.add(
      CompatibilityReason(dimension: dimension, message: message, severity: 'error'),
    );
  }

  void addWarning(String dimension, String message) {
    warnings.add(
      CompatibilityReason(dimension: dimension, message: message, severity: 'warning'),
    );
  }

  void addReason(String dimension, String message) {
    reasons.add(
      CompatibilityReason(dimension: dimension, message: message, severity: 'info'),
    );
  }

  CompatibilityStatus resolveStatus() {
    if (blockers.isNotEmpty) return CompatibilityStatus.incompatible;
    if (warnings.isNotEmpty) return CompatibilityStatus.compatibleWithWarnings;
    if (reasons.isNotEmpty) return CompatibilityStatus.compatible;
    return CompatibilityStatus.insufficientData;
  }

  String get statusLabel => switch (status) {
        CompatibilityStatus.compatible => 'Compatível',
        CompatibilityStatus.compatibleWithWarnings => 'Com ressalvas',
        CompatibilityStatus.incompatible => 'Incompatível',
        CompatibilityStatus.insufficientData => 'Dados insuficientes',
      };
}
