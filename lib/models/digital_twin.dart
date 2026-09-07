import '../data/json_helpers.dart';
import 'compatibility.dart';
import 'detected_hardware.dart';
import 'parts.dart';
import 'pc_build.dart';

class HardwareSnapshot {
  const HardwareSnapshot({
    required this.id,
    required this.capturedAt,
    required this.source,
    required this.build,
    this.detected,
  });

  final String id;
  final DateTime capturedAt;
  final String source;
  final PcBuild build;
  final DetectedHardware? detected;

  factory HardwareSnapshot.fromJson(Map<String, dynamic> json) {
    return HardwareSnapshot(
      id: asString(json['id']),
      capturedAt: asDateTime(json['capturedAt']),
      source: asString(json['source'], 'native'),
      build: PcBuild.fromJson(asMap(json['build'])),
      detected: json['detected'] == null
          ? null
          : DetectedHardware.fromJson(asMap(json['detected'])),
    );
  }
}

class RemoteDigitalTwin {
  const RemoteDigitalTwin({
    required this.machineId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.current,
  });

  final String machineId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final HardwareSnapshot current;

  factory RemoteDigitalTwin.fromJson(String fallbackId, Map<String, dynamic> json) {
    return RemoteDigitalTwin(
      machineId: asString(json['machineId'], fallbackId),
      name: asString(json['name'], 'Máquina sem nome'),
      createdAt: asDateTime(json['createdAt']),
      updatedAt: asDateTime(json['updatedAt']),
      current: HardwareSnapshot.fromJson(asMap(json['current'])),
    );
  }

  PcBuild get build => current.build;

  String get displayName {
    final system = current.detected?.system;
    final fromSystem = [
      system?.manufacturer.trim(),
      system?.model.trim(),
    ].whereType<String>().where((value) => value.isNotEmpty).join(' ');
    if (name.trim().isNotEmpty) return name;
    if (fromSystem.isNotEmpty) return fromSystem;
    return 'Digital Twin';
  }
}

enum RecommendationCategory { ram, ssd, gpu }

extension RecommendationCategoryLabel on RecommendationCategory {
  String get label => switch (this) {
        RecommendationCategory.ram => 'Memória RAM',
        RecommendationCategory.ssd => 'SSD',
        RecommendationCategory.gpu => 'GPU',
      };
}

class MvpRecommendation {
  const MvpRecommendation({
    required this.part,
    required this.result,
    required this.score,
  });

  final Part part;
  final CompatibilityResult result;
  final double score;
}
