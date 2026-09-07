import 'package:management_dashboard/data/parts_repository.dart';
import 'package:management_dashboard/data/twins_repository.dart';
import 'package:management_dashboard/models/digital_twin.dart';
import 'package:management_dashboard/models/parts.dart';
import 'package:management_dashboard/models/pc_build.dart';

class FakeTwinsRepository implements TwinsRepository {
  FakeTwinsRepository(this.twins, {this.error});

  final List<RemoteDigitalTwin> twins;
  final Object? error;

  @override
  Future<List<RemoteDigitalTwin>> fetchTwins() async {
    if (error != null) throw error!;
    return twins;
  }
}

class FakePartsRepository implements PartsRepository {
  FakePartsRepository({
    this.ram = const [],
    this.gpus = const [],
    this.ssds = const [],
  });

  final List<Ram> ram;
  final List<Gpu> gpus;
  final List<Ssd> ssds;

  @override
  Future<List<Ram>> getRam() async => ram;

  @override
  Future<List<Gpu>> getGpus() async => gpus;

  @override
  Future<List<Ssd>> getSsds() async => ssds;
}

Motherboard sampleMotherboard() {
  return const Motherboard(
    id: 'mobo-1',
    name: 'ASUS B650-PLUS',
    brand: 'ASUS',
    socket: 'AM5',
    chipset: 'AMD B650',
    formFactor: 'ATX',
    ramType: 'DDR5',
    ramSlots: 4,
    maxRamCapacity: 128,
    maxRamSpeed: 6400,
    m2Slots: [
      M2Slot(
        key: 'M',
        pcieGeneration: 4,
        lanes: 4,
        supportsNvme: true,
        supportsSata: false,
        formFactors: ['M.2 2280'],
      ),
    ],
    sataConnectors: 4,
    pcieSlots: [
      PcieSlot(generation: 4, lanes: 16, physicalSize: 'x16'),
    ],
    powerConnector: '24-pin ATX',
  );
}

RemoteDigitalTwin sampleTwin() {
  final now = DateTime.utc(2026, 9, 6, 20);
  return RemoteDigitalTwin(
    machineId: 'machine-001',
    name: 'Notebook de Teste',
    createdAt: now,
    updatedAt: now,
    current: HardwareSnapshot(
      id: 'snap-1',
      capturedAt: now,
      source: 'native',
      build: PcBuild(
        id: 'build-1',
        name: 'Notebook de Teste',
        createdAt: now,
        updatedAt: now,
        cpu: const Cpu(
          id: 'cpu-1',
          name: 'AMD Ryzen 7 8700G',
          brand: 'AMD',
          socket: 'AM5',
          chipsets: ['AMD B650'],
          cores: 8,
          threads: 16,
          baseClock: 4.2,
          tdp: 65,
        ),
        motherboard: sampleMotherboard(),
        ram: const [
          Ram(
            id: 'ram-installed',
            name: 'Kingston 16GB',
            brand: 'Kingston',
            type: 'DDR5',
            capacityGb: 16,
            speedMhz: 6000,
            modules: 1,
          ),
        ],
        gpu: const [
          Gpu(
            id: 'gpu-1',
            name: 'AMD Radeon 780M',
            brand: 'AMD',
            vramGb: 0,
            lengthMm: 0,
            slots: 1,
            tdp: 65,
            requiredPsuWatts: 0,
            powerConnectors: [],
            pcieGeneration: 4,
          ),
        ],
        storage: const [
          Ssd(
            id: 'ssd-1',
            name: 'NVMe 512GB',
            brand: 'Generic',
            capacityGb: 512,
            interfaceType: 'NVMe',
            formFactor: 'M.2 2280',
            pcieGeneration: 4,
          ),
        ],
      ),
    ),
  );
}

Ram sampleCompatibleRam() {
  return const Ram(
    id: 'ram-upgrade',
    name: 'Corsair Vengeance 32GB DDR5-6000',
    brand: 'Corsair',
    type: 'DDR5',
    capacityGb: 32,
    speedMhz: 6000,
    modules: 2,
  );
}

Ram sampleIncompatibleRam() {
  return const Ram(
    id: 'ram-ddr4',
    name: 'Kit DDR4 32GB',
    brand: 'Generic',
    type: 'DDR4',
    capacityGb: 32,
    speedMhz: 3200,
    modules: 2,
  );
}
