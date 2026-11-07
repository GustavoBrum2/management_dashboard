import '../data/json_helpers.dart';
import 'parts.dart';

class PcBuild {
  const PcBuild({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.cpu,
    this.motherboard,
    required this.ram,
    required this.gpu,
    required this.storage,
    this.psu,
    this.pcCase,
    this.cooler,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Cpu? cpu;
  final Motherboard? motherboard;
  final List<Ram> ram;
  final List<Gpu> gpu;
  final List<Part> storage;
  final Psu? psu;
  final PcCase? pcCase;
  final Cooler? cooler;

  factory PcBuild.fromJson(Map<String, dynamic> json) {
    return PcBuild(
      id: asString(json['id']),
      name: asString(json['name'], 'Digital Twin'),
      createdAt: asDateTime(json['createdAt']),
      updatedAt: asDateTime(json['updatedAt']),
      cpu: json['cpu'] == null ? null : Cpu.fromJson(asMap(json['cpu'])),
      motherboard: json['motherboard'] == null
          ? null
          : Motherboard.fromJson(asMap(json['motherboard'])),
      ram: asList(json['ram']).map((item) => Ram.fromJson(asMap(item))).toList(),
      gpu: asList(json['gpu']).map((item) => Gpu.fromJson(asMap(item))).toList(),
      storage: asList(json['storage']).map(_storageFromJson).whereType<Part>().toList(),
      psu: json['psu'] == null ? null : Psu.fromJson(asMap(json['psu'])),
      pcCase: json['case'] == null ? null : PcCase.fromJson(asMap(json['case'])),
      cooler: json['cooler'] == null ? null : Cooler.fromJson(asMap(json['cooler'])),
    );
  }

  int get totalRamGb => ram.fold(0, (sum, item) => sum + item.capacityGb);

  String get ramSummary {
    if (ram.isEmpty) return 'Não identificado';
    return ram
        .map((item) {
          final speed = item.speedMhz > 0 ? ' ${item.speedMhz} MHz' : '';
          return '${item.capacityGb} GB ${item.type}$speed';
        })
        .join(' + ');
  }

  String get gpuSummary {
    if (gpu.isEmpty) return 'Não identificado';
    return gpu.map((item) => item.name).join(' + ');
  }

  String get storageSummary {
    if (storage.isEmpty) return 'Não identificado';
    return storage
        .map((item) => '${item.name} (${storageCapacityOf(item)} GB)')
        .join(' + ');
  }

  PcBuild copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    Cpu? cpu,
    Motherboard? motherboard,
    List<Ram>? ram,
    List<Gpu>? gpu,
    List<Part>? storage,
    Psu? psu,
    PcCase? pcCase,
    Cooler? cooler,
  }) {
    return PcBuild(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cpu: cpu ?? this.cpu,
      motherboard: motherboard ?? this.motherboard,
      ram: ram ?? this.ram,
      gpu: gpu ?? this.gpu,
      storage: storage ?? this.storage,
      psu: psu ?? this.psu,
      pcCase: pcCase ?? this.pcCase,
      cooler: cooler ?? this.cooler,
    );
  }
}

Part? _storageFromJson(dynamic item) {
  final json = asMap(item);
  final category = asString(json['category']);
  if (category == 'hdd') return Hdd.fromJson(json);
  if (category == 'ssd' || json.containsKey('interface')) {
    return Ssd.fromJson(json);
  }
  return null;
}
