int normalizePcieGeneration(dynamic value) {
  final match = RegExp(r'\d+').firstMatch('$value');
  final parsed = int.tryParse(match?.group(0) ?? '') ?? 4;
  if (parsed >= 5) return 5;
  if (parsed <= 3) return 3;
  return 4;
}

String normalizeRamType(dynamic value) {
  final upper = asUpper(value);
  if (upper.contains('DDR5')) return 'DDR5';
  if (upper.contains('DDR3')) return 'DDR3';
  return 'DDR4';
}

String normalizeMotherboardFormFactor(dynamic value) {
  final lower = asLower(value);
  if (lower.contains('mini')) return 'Mini-ITX';
  if (lower.contains('micro') || lower.contains('matx') || lower.contains('m-atx')) {
    return 'Micro-ATX';
  }
  if (lower.contains('e-atx') || lower.contains('eatx')) return 'E-ATX';
  return 'ATX';
}

String normalizeStorageInterface(dynamic value) {
  return asLower(value).contains('nvme') ? 'NVMe' : 'SATA';
}

String normalizeStorageFormFactor(dynamic value) {
  final lower = asLower(value);
  if (lower.contains('2230')) return 'M.2 2230';
  if (lower.contains('2242')) return 'M.2 2242';
  if (lower.contains('2260')) return 'M.2 2260';
  if (lower.contains('m.2') || lower.contains('2280')) return 'M.2 2280';
  if (lower.contains('3.5')) return '3.5"';
  return '2.5"';
}

String normalizeHddFormFactor(dynamic value) {
  return asLower(value).contains('2.5') ? '2.5"' : '3.5"';
}

String normalizeM2Key(dynamic value) {
  final raw = '$value';
  if (raw == 'B') return 'B';
  if (raw == 'B+M') return 'B+M';
  return 'M';
}

String normalizePciePhysicalSize(dynamic value) {
  const allowed = {'x1', 'x4', 'x8', 'x16'};
  final raw = '$value';
  if (allowed.contains(raw)) return raw;
  return 'x16';
}

String asLower(dynamic value) => '$value'.toLowerCase();

String asUpper(dynamic value) => '$value'.toUpperCase();
