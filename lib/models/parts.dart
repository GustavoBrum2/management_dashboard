import '../data/json_helpers.dart';
import '../domain/normalize.dart';

sealed class Part {
  const Part({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    this.rawSpecs,
  });

  final String id;
  final String name;
  final String brand;
  final String category;
  final String? rawSpecs;
}

class Cpu extends Part {
  const Cpu({
    required super.id,
    required super.name,
    required super.brand,
    required this.socket,
    required this.chipsets,
    required this.cores,
    required this.threads,
    required this.baseClock,
    this.boostClock,
    required this.tdp,
    this.integratedGraphics,
    super.rawSpecs,
  }) : super(category: 'cpu');

  final String socket;
  final List<String> chipsets;
  final int cores;
  final int threads;
  final double baseClock;
  final double? boostClock;
  final int tdp;
  final String? integratedGraphics;

  factory Cpu.fromJson(Map<String, dynamic> json) {
    return Cpu(
      id: asString(json['id']),
      name: asString(json['name']),
      brand: asString(json['brand']),
      socket: asString(json['socket']),
      chipsets: asList(json['chipsets']).map(asString).toList(),
      cores: asInt(json['cores']),
      threads: asInt(json['threads']),
      baseClock: asDouble(json['baseClock']),
      boostClock: json['boostClock'] == null ? null : asDouble(json['boostClock']),
      tdp: asInt(json['tdp']),
      integratedGraphics: json['integratedGraphics'] == null
          ? null
          : asString(json['integratedGraphics']),
      rawSpecs: json['rawSpecs'] == null ? null : asString(json['rawSpecs']),
    );
  }
}

class M2Slot {
  const M2Slot({
    required this.key,
    required this.pcieGeneration,
    required this.lanes,
    required this.supportsNvme,
    required this.supportsSata,
    required this.formFactors,
  });

  final String key;
  final int pcieGeneration;
  final int lanes;
  final bool supportsNvme;
  final bool supportsSata;
  final List<String> formFactors;

  factory M2Slot.fromJson(Map<String, dynamic> json) {
    return M2Slot(
      key: normalizeM2Key(json['key']),
      pcieGeneration: normalizePcieGeneration(json['pcieGeneration']),
      lanes: asInt(json['lanes']),
      supportsNvme: asBool(json['supportsNvme']),
      supportsSata: asBool(json['supportsSata']),
      formFactors: asList(json['formFactors']).map(normalizeStorageFormFactor).toList(),
    );
  }
}

class PcieSlot {
  const PcieSlot({
    required this.generation,
    required this.lanes,
    required this.physicalSize,
  });

  final int generation;
  final int lanes;
  final String physicalSize;

  factory PcieSlot.fromJson(Map<String, dynamic> json) {
    return PcieSlot(
      generation: normalizePcieGeneration(json['generation']),
      lanes: asInt(json['lanes']),
      physicalSize: normalizePciePhysicalSize(json['physicalSize']),
    );
  }
}

class Motherboard extends Part {
  const Motherboard({
    required super.id,
    required super.name,
    required super.brand,
    required this.socket,
    required this.chipset,
    required this.formFactor,
    required this.ramType,
    required this.ramSlots,
    required this.maxRamCapacity,
    required this.maxRamSpeed,
    required this.m2Slots,
    required this.sataConnectors,
    required this.pcieSlots,
    required this.powerConnector,
    super.rawSpecs,
  }) : super(category: 'motherboard');

  final String socket;
  final String chipset;
  final String formFactor;
  final String ramType;
  final int ramSlots;
  final int maxRamCapacity;
  final int maxRamSpeed;
  final List<M2Slot> m2Slots;
  final int sataConnectors;
  final List<PcieSlot> pcieSlots;
  final String powerConnector;

  factory Motherboard.fromJson(Map<String, dynamic> json) {
    return Motherboard(
      id: asString(json['id']),
      name: asString(json['name']),
      brand: asString(json['brand']),
      socket: asString(json['socket']),
      chipset: asString(json['chipset']),
      formFactor: normalizeMotherboardFormFactor(json['formFactor']),
      ramType: normalizeRamType(json['ramType']),
      ramSlots: asInt(json['ramSlots']),
      maxRamCapacity: asInt(json['maxRamCapacity']),
      maxRamSpeed: asInt(json['maxRamSpeed']),
      m2Slots: asList(json['m2Slots']).map((item) => M2Slot.fromJson(asMap(item))).toList(),
      sataConnectors: asInt(json['sataConnectors']),
      pcieSlots: asList(json['pcieSlots']).map((item) => PcieSlot.fromJson(asMap(item))).toList(),
      powerConnector: asString(json['powerConnector']),
      rawSpecs: json['rawSpecs'] == null ? null : asString(json['rawSpecs']),
    );
  }
}

class Ram extends Part {
  const Ram({
    required super.id,
    required super.name,
    required super.brand,
    required this.type,
    required this.capacityGb,
    required this.speedMhz,
    required this.modules,
    this.latency,
    super.rawSpecs,
  }) : super(category: 'ram');

  final String type;
  final int capacityGb;
  final int speedMhz;
  final int modules;
  final String? latency;

  factory Ram.fromJson(Map<String, dynamic> json) {
    return Ram(
      id: asString(json['id']),
      name: asString(json['name']),
      brand: asString(json['brand']),
      type: normalizeRamType(json['type']),
      capacityGb: asInt(json['capacityGb']),
      speedMhz: asInt(json['speedMhz']),
      modules: asInt(json['modules'], 1),
      latency: json['latency'] == null ? null : asString(json['latency']),
      rawSpecs: json['rawSpecs'] == null ? null : asString(json['rawSpecs']),
    );
  }
}

class Gpu extends Part {
  const Gpu({
    required super.id,
    required super.name,
    required super.brand,
    required this.vramGb,
    required this.lengthMm,
    required this.slots,
    required this.tdp,
    required this.requiredPsuWatts,
    required this.powerConnectors,
    required this.pcieGeneration,
    super.rawSpecs,
  }) : super(category: 'gpu');

  final int vramGb;
  final int lengthMm;
  final int slots;
  final int tdp;
  final int requiredPsuWatts;
  final List<String> powerConnectors;
  final int pcieGeneration;

  factory Gpu.fromJson(Map<String, dynamic> json) {
    return Gpu(
      id: asString(json['id']),
      name: asString(json['name']),
      brand: asString(json['brand']),
      vramGb: asInt(json['vramGb']),
      lengthMm: asInt(json['lengthMm']),
      slots: asInt(json['slots'], 2),
      tdp: asInt(json['tdp']),
      requiredPsuWatts: asInt(json['requiredPsuWatts']),
      powerConnectors: asList(json['powerConnectors']).map(asString).toList(),
      pcieGeneration: normalizePcieGeneration(json['pcieGeneration']),
      rawSpecs: json['rawSpecs'] == null ? null : asString(json['rawSpecs']),
    );
  }
}

class Ssd extends Part {
  const Ssd({
    required super.id,
    required super.name,
    required super.brand,
    required this.capacityGb,
    required this.interfaceType,
    required this.formFactor,
    this.pcieGeneration,
    this.lanes,
    this.readSpeedMbps,
    this.writeSpeedMbps,
    super.rawSpecs,
  }) : super(category: 'ssd');

  final int capacityGb;
  final String interfaceType;
  final String formFactor;
  final int? pcieGeneration;
  final int? lanes;
  final int? readSpeedMbps;
  final int? writeSpeedMbps;

  factory Ssd.fromJson(Map<String, dynamic> json) {
    return Ssd(
      id: asString(json['id']),
      name: asString(json['name']),
      brand: asString(json['brand']),
      capacityGb: asInt(json['capacityGb']),
      interfaceType: normalizeStorageInterface(json['interface']),
      formFactor: normalizeStorageFormFactor(json['formFactor']),
      pcieGeneration: json['pcieGeneration'] == null
          ? null
          : normalizePcieGeneration(json['pcieGeneration']),
      lanes: asNullableInt(json['lanes']),
      readSpeedMbps: asNullableInt(json['readSpeedMbps']),
      writeSpeedMbps: asNullableInt(json['writeSpeedMbps']),
      rawSpecs: json['rawSpecs'] == null ? null : asString(json['rawSpecs']),
    );
  }
}

class Hdd extends Part {
  const Hdd({
    required super.id,
    required super.name,
    required super.brand,
    required this.capacityGb,
    required this.rpm,
    required this.formFactor,
    this.interfaceType = 'SATA',
    super.rawSpecs,
  }) : super(category: 'hdd');

  final int capacityGb;
  final int rpm;
  final String formFactor;
  final String interfaceType;

  factory Hdd.fromJson(Map<String, dynamic> json) {
    return Hdd(
      id: asString(json['id']),
      name: asString(json['name']),
      brand: asString(json['brand']),
      capacityGb: asInt(json['capacityGb']),
      rpm: asInt(json['rpm'], 7200),
      formFactor: normalizeHddFormFactor(json['formFactor']),
      interfaceType: 'SATA',
      rawSpecs: json['rawSpecs'] == null ? null : asString(json['rawSpecs']),
    );
  }
}

class PsuConnectors {
  const PsuConnectors({
    required this.atx24pin,
    required this.cpu8pin,
    required this.cpu4pin,
    required this.pcie8pin,
    required this.pcie6pin,
    required this.sata,
    required this.molex,
  });

  final int atx24pin;
  final int cpu8pin;
  final int cpu4pin;
  final int pcie8pin;
  final int pcie6pin;
  final int sata;
  final int molex;

  factory PsuConnectors.fromJson(Map<String, dynamic> json) {
    return PsuConnectors(
      atx24pin: asInt(json['atx24pin']),
      cpu8pin: asInt(json['cpu8pin']),
      cpu4pin: asInt(json['cpu4pin']),
      pcie8pin: asInt(json['pcie8pin']),
      pcie6pin: asInt(json['pcie6pin']),
      sata: asInt(json['sata']),
      molex: asInt(json['molex']),
    );
  }
}

class Psu extends Part {
  const Psu({
    required super.id,
    required super.name,
    required super.brand,
    required this.wattage,
    this.efficiency,
    this.modular,
    required this.connectors,
    super.rawSpecs,
  }) : super(category: 'psu');

  final int wattage;
  final String? efficiency;
  final String? modular;
  final PsuConnectors connectors;

  factory Psu.fromJson(Map<String, dynamic> json) {
    return Psu(
      id: asString(json['id']),
      name: asString(json['name']),
      brand: asString(json['brand']),
      wattage: asInt(json['wattage']),
      efficiency: json['efficiency'] == null ? null : asString(json['efficiency']),
      modular: json['modular'] == null ? null : asString(json['modular']),
      connectors: PsuConnectors.fromJson(asMap(json['connectors'])),
      rawSpecs: json['rawSpecs'] == null ? null : asString(json['rawSpecs']),
    );
  }
}

class PcCase extends Part {
  const PcCase({
    required super.id,
    required super.name,
    required super.brand,
    required this.supportedFormFactors,
    required this.maxGpuLengthMm,
    required this.maxCoolerHeightMm,
    required this.driveBays35,
    required this.driveBays25,
    super.rawSpecs,
  }) : super(category: 'case');

  final List<String> supportedFormFactors;
  final int maxGpuLengthMm;
  final int maxCoolerHeightMm;
  final int driveBays35;
  final int driveBays25;

  factory PcCase.fromJson(Map<String, dynamic> json) {
    return PcCase(
      id: asString(json['id']),
      name: asString(json['name']),
      brand: asString(json['brand']),
      supportedFormFactors: asList(json['supportedFormFactors']).map(asString).toList(),
      maxGpuLengthMm: asInt(json['maxGpuLengthMm']),
      maxCoolerHeightMm: asInt(json['maxCoolerHeightMm']),
      driveBays35: asInt(json['driveBays35']),
      driveBays25: asInt(json['driveBays25']),
      rawSpecs: json['rawSpecs'] == null ? null : asString(json['rawSpecs']),
    );
  }
}

class Cooler extends Part {
  const Cooler({
    required super.id,
    required super.name,
    required super.brand,
    required this.type,
    required this.heightMm,
    required this.supportedSockets,
    this.tdpRating,
    this.radiatorSize,
    super.rawSpecs,
  }) : super(category: 'cooler');

  final String type;
  final int heightMm;
  final List<String> supportedSockets;
  final int? tdpRating;
  final int? radiatorSize;

  factory Cooler.fromJson(Map<String, dynamic> json) {
    return Cooler(
      id: asString(json['id']),
      name: asString(json['name']),
      brand: asString(json['brand']),
      type: asString(json['type'], 'air'),
      heightMm: asInt(json['heightMm']),
      supportedSockets: asList(json['supportedSockets']).map(asString).toList(),
      tdpRating: asNullableInt(json['tdpRating']),
      radiatorSize: asNullableInt(json['radiatorSize']),
      rawSpecs: json['rawSpecs'] == null ? null : asString(json['rawSpecs']),
    );
  }
}

Part? partFromJson(Map<String, dynamic> json) {
  switch (asString(json['category'])) {
    case 'cpu':
      return Cpu.fromJson(json);
    case 'motherboard':
      return Motherboard.fromJson(json);
    case 'ram':
      return Ram.fromJson(json);
    case 'gpu':
      return Gpu.fromJson(json);
    case 'ssd':
      return Ssd.fromJson(json);
    case 'hdd':
      return Hdd.fromJson(json);
    case 'psu':
      return Psu.fromJson(json);
    case 'case':
      return PcCase.fromJson(json);
    case 'cooler':
      return Cooler.fromJson(json);
    default:
      return null;
  }
}

String storageInterfaceOf(Part part) {
  return switch (part) {
    Ssd(:final interfaceType) => interfaceType,
    Hdd(:final interfaceType) => interfaceType,
    _ => '',
  };
}

int storageCapacityOf(Part part) {
  return switch (part) {
    Ssd(:final capacityGb) => capacityGb,
    Hdd(:final capacityGb) => capacityGb,
    _ => 0,
  };
}
