import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/ocr/label_ocr_service.dart';
import '../data/repositories/basal_repository.dart';
import '../data/repositories/food_label_repository.dart';
import '../data/repositories/glucose_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../domain/models/basal_entry.dart';
import '../domain/models/dose_settings.dart';
import '../domain/models/food_label.dart';
import '../domain/models/glucose_entry.dart';
import '../domain/services/bolus_calculator.dart';
import '../domain/services/nutrition_label_parser.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final basalRepositoryProvider = Provider<BasalRepository>((ref) {
  return BasalRepository(ref.watch(appDatabaseProvider));
});

final glucoseRepositoryProvider = Provider<GlucoseRepository>((ref) {
  return GlucoseRepository(ref.watch(appDatabaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final bolusCalculatorProvider = Provider<BolusCalculator>((ref) {
  return const BolusCalculator();
});

final foodLabelRepositoryProvider = Provider<FoodLabelRepository>((ref) {
  return FoodLabelRepository(ref.watch(appDatabaseProvider));
});

final labelOcrServiceProvider = Provider<LabelOcrService>((ref) {
  return createLabelOcrService();
});

final nutritionLabelParserProvider = Provider<NutritionLabelParser>((ref) {
  return const NutritionLabelParser();
});

final doseSettingsProvider =
    StateNotifierProvider<DoseSettingsNotifier, AsyncValue<DoseSettings>>((ref) {
  return DoseSettingsNotifier(ref.watch(settingsRepositoryProvider));
});

class DoseSettingsNotifier extends StateNotifier<AsyncValue<DoseSettings>> {
  DoseSettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final SettingsRepository _repository;

  Future<void> _load() async {
    try {
      final settings = await _repository.load();
      state = AsyncValue.data(settings);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> update(DoseSettings settings) async {
    await _repository.save(settings);
    state = AsyncValue.data(settings);
  }
}

final basalEntriesProvider =
    StateNotifierProvider<BasalEntriesNotifier, AsyncValue<List<BasalEntry>>>((ref) {
  return BasalEntriesNotifier(ref.watch(basalRepositoryProvider));
});

class BasalEntriesNotifier extends StateNotifier<AsyncValue<List<BasalEntry>>> {
  BasalEntriesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final BasalRepository _repository;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final entries = await _repository.getAll();
      state = AsyncValue.data(entries);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> add(BasalEntry entry) async {
    await _repository.insert(entry);
    await _load();
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    await _load();
  }
}

final foodLabelsProvider =
    StateNotifierProvider<FoodLabelsNotifier, AsyncValue<List<FoodLabel>>>((ref) {
  return FoodLabelsNotifier(ref.watch(foodLabelRepositoryProvider));
});

class FoodLabelsNotifier extends StateNotifier<AsyncValue<List<FoodLabel>>> {
  FoodLabelsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final FoodLabelRepository _repository;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final labels = await _repository.getAll();
      state = AsyncValue.data(labels);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> add(FoodLabel label) async {
    await _repository.insert(label);
    await _load();
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    await _load();
  }
}

final glucoseEntriesProvider =
    StateNotifierProvider<GlucoseEntriesNotifier, AsyncValue<List<GlucoseEntry>>>((ref) {
  return GlucoseEntriesNotifier(ref.watch(glucoseRepositoryProvider));
});

class GlucoseEntriesNotifier extends StateNotifier<AsyncValue<List<GlucoseEntry>>> {
  GlucoseEntriesNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  final GlucoseRepository _repository;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final entries = await _repository.getAll();
      state = AsyncValue.data(entries);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> add(GlucoseEntry entry) async {
    await _repository.insert(entry);
    await _load();
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    await _load();
  }
}
