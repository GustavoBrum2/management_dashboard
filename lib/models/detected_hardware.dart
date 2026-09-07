import '../data/json_helpers.dart';

class DetectedCpu {
  const DetectedCpu({
    required this.modelName,
    required this.manufacturer,
    required this.architecture,
    required this.cores,
    required this.threads,
    required this.confidence,
  });

  final String modelName;
  final String manufacturer;
  final String architecture;
  final int cores;
  final int threads;
  final String confidence;

  factory DetectedCpu.fromJson(Map<String, dynamic> json) {
    return DetectedCpu(
      modelName: asString(json['modelName']),
      manufacturer: asString(json['manufacturer']),
      architecture: asString(json['architecture']),
      cores: asInt(json['cores']),
      threads: asInt(json['threads']),
      confidence: asString(json['confidence'], 'medium'),
    );
  }
}

class DetectedGpu {
  const DetectedGpu({
    required this.name,
    required this.vendor,
    required this.driverVersion,
    required this.confidence,
  });

  final String name;
  final String vendor;
  final String driverVersion;
  final String confidence;

  factory DetectedGpu.fromJson(Map<String, dynamic> json) {
    return DetectedGpu(
      name: asString(json['name']),
      vendor: asString(json['vendor']),
      driverVersion: asString(json['driverVersion']),
      confidence: asString(json['confidence'], 'medium'),
    );
  }
}

class DetectedRamStick {
  const DetectedRamStick({
    required this.manufacturer,
    required this.partNumber,
    required this.capacityGb,
    required this.speedMhz,
    required this.slot,
  });

  final String manufacturer;
  final String partNumber;
  final int capacityGb;
  final int speedMhz;
  final String slot;

  factory DetectedRamStick.fromJson(Map<String, dynamic> json) {
    return DetectedRamStick(
      manufacturer: asString(json['manufacturer']),
      partNumber: asString(json['partNumber']),
      capacityGb: asInt(json['capacityGb']),
      speedMhz: asInt(json['speedMhz']),
      slot: asString(json['slot']),
    );
  }
}

class DetectedRam {
  const DetectedRam({
    required this.totalGb,
    required this.modules,
    required this.sticks,
    required this.confidence,
  });

  final int totalGb;
  final int modules;
  final List<DetectedRamStick> sticks;
  final String confidence;

  factory DetectedRam.fromJson(Map<String, dynamic> json) {
    return DetectedRam(
      totalGb: asInt(json['totalGb']),
      modules: asInt(json['modules']),
      sticks: asList(json['sticks']).map((item) => DetectedRamStick.fromJson(asMap(item))).toList(),
      confidence: asString(json['confidence'], 'medium'),
    );
  }
}

class DetectedStorage {
  const DetectedStorage({
    required this.name,
    required this.manufacturer,
    required this.model,
    required this.capacityGb,
    required this.interfaceType,
    required this.mediaType,
    required this.type,
    required this.confidence,
  });

  final String name;
  final String manufacturer;
  final String model;
  final int capacityGb;
  final String interfaceType;
  final String mediaType;
  final String type;
  final String confidence;

  factory DetectedStorage.fromJson(Map<String, dynamic> json) {
    return DetectedStorage(
      name: asString(json['name']),
      manufacturer: asString(json['manufacturer']),
      model: asString(json['model']),
      capacityGb: asInt(json['capacityGb']),
      interfaceType: asString(json['interfaceType']),
      mediaType: asString(json['mediaType']),
      type: asString(json['type'], 'unknown'),
      confidence: asString(json['confidence'], 'medium'),
    );
  }
}

class DetectedMotherboard {
  const DetectedMotherboard({
    required this.manufacturer,
    required this.product,
    required this.confidence,
  });

  final String manufacturer;
  final String product;
  final String confidence;

  factory DetectedMotherboard.fromJson(Map<String, dynamic> json) {
    return DetectedMotherboard(
      manufacturer: asString(json['manufacturer']),
      product: asString(json['product']),
      confidence: asString(json['confidence'], 'medium'),
    );
  }
}

class DetectedSystem {
  const DetectedSystem({
    required this.manufacturer,
    required this.model,
  });

  final String manufacturer;
  final String model;

  factory DetectedSystem.fromJson(Map<String, dynamic> json) {
    return DetectedSystem(
      manufacturer: asString(json['manufacturer']),
      model: asString(json['model']),
    );
  }
}

class DetectedHardware {
  const DetectedHardware({
    required this.source,
    this.cpu,
    required this.gpus,
    this.ram,
    required this.storage,
    this.motherboard,
    this.system,
    required this.detectedAt,
  });

  final String source;
  final DetectedCpu? cpu;
  final List<DetectedGpu> gpus;
  final DetectedRam? ram;
  final List<DetectedStorage> storage;
  final DetectedMotherboard? motherboard;
  final DetectedSystem? system;
  final DateTime detectedAt;

  factory DetectedHardware.fromJson(Map<String, dynamic> json) {
    return DetectedHardware(
      source: asString(json['source'], 'native'),
      cpu: json['cpu'] == null ? null : DetectedCpu.fromJson(asMap(json['cpu'])),
      gpus: asList(json['gpus']).map((item) => DetectedGpu.fromJson(asMap(item))).toList(),
      ram: json['ram'] == null ? null : DetectedRam.fromJson(asMap(json['ram'])),
      storage: asList(json['storage']).map((item) => DetectedStorage.fromJson(asMap(item))).toList(),
      motherboard: json['motherboard'] == null
          ? null
          : DetectedMotherboard.fromJson(asMap(json['motherboard'])),
      system: json['system'] == null ? null : DetectedSystem.fromJson(asMap(json['system'])),
      detectedAt: asDateTime(json['detectedAt']),
    );
  }
}
