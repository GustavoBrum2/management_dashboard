import 'package:flutter/foundation.dart';

import '../data/parts_repository.dart';
import '../data/twins_repository.dart';
import '../models/digital_twin.dart';
import '../models/parts.dart';
import '../models/pc_build.dart';
import '../models/upgrade_simulation.dart';
import '../services/recommendation_service.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required TwinsRepository twinsRepository,
    required PartsRepository partsRepository,
  })  : _twinsRepository = twinsRepository,
        _recommendationService = RecommendationService(partsRepository);

  final TwinsRepository _twinsRepository;
  final RecommendationService _recommendationService;
  final Map<String, UpgradeSimulation> _simulations = {};

  List<RemoteDigitalTwin> twins = const [];
  bool loading = true;
  bool generatingRecommendations = false;
  String? error;
  String searchQuery = '';
  RemoteDigitalTwin? selectedTwin;
  RecommendationCategory recommendationCategory = RecommendationCategory.ram;
  List<MvpRecommendation> recommendations = const [];

  UpgradeSimulation get selectedSimulation {
    final id = selectedTwin?.machineId;
    if (id == null) return const UpgradeSimulation();
    return _simulations[id] ?? const UpgradeSimulation();
  }

  PcBuild? get selectedOriginalBuild => selectedTwin?.build;

  PcBuild? get selectedViewedBuild {
    final original = selectedOriginalBuild;
    if (original == null) return null;
    return applySimulation(original, selectedSimulation);
  }

  UpgradeSimulation simulationFor(String machineId) {
    return _simulations[machineId] ?? const UpgradeSimulation();
  }

  int get simulatedTwinCount => _simulations.values.where((item) => item.isNotEmpty).length;

  List<RemoteDigitalTwin> get filteredTwins {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return twins;
    return twins.where((twin) {
      final simulation = simulationFor(twin.machineId);
      final haystack = [
        twin.displayName,
        twin.machineId,
        twin.build.cpu?.name ?? '',
        twin.build.motherboard?.name ?? '',
        twin.build.gpuSummary,
        twin.build.ramSummary,
        simulation.ram?.name ?? '',
        simulation.gpu?.name ?? '',
        simulation.ssd?.name ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Future<void> loadTwins({bool keepSelection = false}) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final loaded = await _twinsRepository.fetchTwins();
      twins = loaded;
      final selectedId = selectedTwin?.machineId;
      if (keepSelection && selectedId != null) {
        selectedTwin = loaded
                .where((twin) => twin.machineId == selectedId)
                .firstOrNull ??
            selectedTwin;
      }
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      error = err is Exception ? err.toString().replaceFirst('Exception: ', '') : err.toString();
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void selectTwin(RemoteDigitalTwin twin) {
    if (selectedTwin?.machineId == twin.machineId) return;
    if (selectedTwin != null && selectedTwin!.machineId != twin.machineId) {
      recommendations = const [];
    }
    selectedTwin = twin;
    notifyListeners();
  }

  void clearSelection() {
    selectedTwin = null;
    notifyListeners();
  }

  void setRecommendationCategory(RecommendationCategory category) {
    if (recommendationCategory == category) return;
    recommendationCategory = category;
    recommendations = const [];
    notifyListeners();
  }

  Future<void> generateRecommendations() async {
    final twin = selectedTwin;
    final build = selectedViewedBuild;
    if (twin == null || build == null) return;

    generatingRecommendations = true;
    error = null;
    notifyListeners();

    try {
      final results = await _recommendationService.recommend(
        build,
        recommendationCategory,
      );
      recommendations = results;
      generatingRecommendations = false;
      notifyListeners();
    } catch (err) {
      generatingRecommendations = false;
      error = err is Exception ? err.toString().replaceFirst('Exception: ', '') : err.toString();
      notifyListeners();
    }
  }

  void simulateRecommendation(MvpRecommendation recommendation) {
    final twin = selectedTwin;
    if (twin == null) return;
    final current = selectedSimulation;
    _simulations[twin.machineId] = current.withPart(recommendation.part);
    notifyListeners();
  }

  void removeSimulation(RecommendationCategory category) {
    final twin = selectedTwin;
    if (twin == null) return;
    final updated = selectedSimulation.without(category);
    if (updated.isEmpty) {
      _simulations.remove(twin.machineId);
    } else {
      _simulations[twin.machineId] = updated;
    }
    notifyListeners();
  }

  bool isSimulating(Part part) => selectedSimulation.contains(part);
}
