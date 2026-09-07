import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/parts.dart';

abstract class PartsRepository {
  Future<List<Ram>> getRam();
  Future<List<Gpu>> getGpus();
  Future<List<Ssd>> getSsds();
}

class AssetPartsRepository implements PartsRepository {
  AssetPartsRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  List<Ram>? _ram;
  List<Gpu>? _gpus;
  List<Ssd>? _ssds;

  @override
  Future<List<Ram>> getRam() async {
    return _ram ??= await _loadList('assets/data/ram.json', Ram.fromJson);
  }

  @override
  Future<List<Gpu>> getGpus() async {
    return _gpus ??= await _loadList('assets/data/gpus.json', Gpu.fromJson);
  }

  @override
  Future<List<Ssd>> getSsds() async {
    return _ssds ??= await _loadList('assets/data/ssds.json', Ssd.fromJson);
  }

  Future<List<T>> _loadList<T>(
    String assetPath,
    T Function(Map<String, dynamic> json) parser,
  ) async {
    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => parser(Map<String, dynamic>.from(item)))
        .toList();
  }
}
