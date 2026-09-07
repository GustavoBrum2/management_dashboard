import '../../models/compatibility.dart';
import '../../models/parts.dart';
import '../../models/pc_build.dart';

CompatibilityResult checkMotherboardCompatibility(PcBuild build, Motherboard motherboard) {
  final result = CompatibilityResult.empty('motherboard', motherboard.name);

  final cpu = build.cpu;
  if (cpu != null) {
    if (cpu.socket != motherboard.socket) {
      result.addBlocker(
        'socket',
        'Sua CPU cadastrada usa socket ${cpu.socket}, mas a placa-mãe analisada usa socket ${motherboard.socket}.',
      );
    } else {
      result.addReason('socket', 'Socket ${motherboard.socket} compatível com a CPU cadastrada.');
    }

    if (cpu.chipsets.isNotEmpty) {
      final supported = cpu.chipsets.any(
        (chipset) => chipset.toLowerCase() == motherboard.chipset.toLowerCase(),
      );
      if (supported) {
        result.addReason(
          'chipset',
          'Chipset ${motherboard.chipset} aparece como suportado para sua CPU na base local.',
        );
      } else {
        result.addWarning(
          'chipset',
          'O chipset ${motherboard.chipset} não apareceu na lista de chipsets da CPU cadastrada. Pode exigir validação de BIOS/lista de suporte da fabricante.',
        );
      }
    }
  } else {
    result.addWarning(
      'cpu',
      'CPU não cadastrada. A compatibilidade de socket/chipset não pôde ser validada.',
    );
  }

  for (final ram in build.ram) {
    if (ram.type != motherboard.ramType) {
      result.addBlocker(
        'ram_type',
        'Sua memória ${ram.name} é ${ram.type}, mas a placa-mãe analisada suporta ${motherboard.ramType}.',
      );
    }
  }

  final totalRamCapacity = build.ram.fold(0, (sum, ram) => sum + ram.capacityGb);
  final usedRamSlots = build.ram.fold(0, (sum, ram) => sum + ram.modules);

  if (totalRamCapacity > motherboard.maxRamCapacity) {
    result.addBlocker(
      'ram_capacity',
      'Sua RAM total é ${totalRamCapacity}GB, mas a placa-mãe analisada suporta no máximo ${motherboard.maxRamCapacity}GB.',
    );
  } else if (build.ram.isNotEmpty) {
    result.addReason(
      'ram_capacity',
      'Capacidade de RAM cadastrada dentro do limite da placa-mãe analisada.',
    );
  }

  if (usedRamSlots > motherboard.ramSlots) {
    result.addBlocker(
      'ram_slots',
      'Sua build usa $usedRamSlots módulo(s) de RAM, mas a placa-mãe analisada possui ${motherboard.ramSlots} slot(s).',
    );
  }

  if (build.gpu.isNotEmpty) {
    final hasX16Slot = motherboard.pcieSlots.any((slot) => slot.physicalSize == 'x16');
    if (!hasX16Slot) {
      result.addBlocker(
        'pcie',
        'A placa-mãe analisada não possui slot PCIe x16 para a GPU cadastrada.',
      );
    } else {
      result.addReason('pcie', 'Slot PCIe x16 disponível para a GPU cadastrada.');
    }
  }

  final sataStorageCount = build.storage.where((item) => storageInterfaceOf(item) == 'SATA').length;
  if (sataStorageCount > motherboard.sataConnectors) {
    result.addBlocker(
      'sata',
      'Sua build possui $sataStorageCount dispositivo(s) SATA, mas a placa-mãe analisada possui ${motherboard.sataConnectors} conector(es) SATA.',
    );
  }

  final nvmeStorageCount = build.storage.where((item) {
    return item is Ssd && item.interfaceType == 'NVMe';
  }).length;
  final nvmeSlots = motherboard.m2Slots.where((slot) => slot.supportsNvme).length;
  if (nvmeStorageCount > nvmeSlots) {
    result.addBlocker(
      'm2_nvme',
      'Sua build possui $nvmeStorageCount SSD(s) NVMe, mas a placa-mãe analisada possui $nvmeSlots slot(s) M.2 NVMe compatíveis.',
    );
  }

  result.status = result.resolveStatus();
  result.summary = switch (result.status) {
    CompatibilityStatus.compatible =>
      'A placa-mãe é compatível com os principais componentes cadastrados.',
    CompatibilityStatus.incompatible => 'A placa-mãe não é compatível com a build atual.',
    CompatibilityStatus.compatibleWithWarnings =>
      'A placa-mãe parece compatível, mas exige algumas validações adicionais.',
    CompatibilityStatus.insufficientData => 'Dados insuficientes para concluir a análise da placa-mãe.',
  };
  return result;
}
