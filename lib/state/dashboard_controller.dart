import 'package:flutter/foundation.dart';

import '../data/parts_repository.dart';
import '../data/twins_repository.dart';
import '../models/digital_twin.dart';
import '../services/recommendation_service.dart';

class DashboardController extends ChangeNotifier {
  DashboardController({
    required TwinsRepository twinsRepository,
    required PartsRepository partsRepository,
  })  : _twinsRepository = twinsRepository,
        _recommendationService = RecommendationService(partsRepository);

  final TwinsRepository _twinsRepository;
  final RecommendationService _recommendationService;

  List<RemoteDigitalTwin> twins = const [];
  bool loading = true;
  bool generatingRecommendations = false;
  String? error;
  String searchQuery = '';
  RemoteDigitalTwin? selectedTwin;
  RecommendationCategory recommendationCategory = RecommendationCategory.ram;
  List<MvpRecommendation> recommendations = const [];

  List<RemoteDigitalTwin> get filteredTwins {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return twins;
    return twins.where((twin) {
      final haystack = [
        twin.displayName,
        twin.machineId,
        twin.build.cpu?.name ?? '',
        twin.build.motherboard?.name ?? '',
        twin.build.gpuSummary,
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
    selectedTwin = twin;
    recommendations = const [];
    notifyListeners();
  }

  void clearSelection() {
    selectedTwin = null;
    recommendations = const [];
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
    if (twin == null) return;

    generatingRecommendations = true;
    error = null;
    notifyListeners();

    try {
      final results = await _recommendationService.recommend(
        twin.build,
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
}
