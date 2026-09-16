import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../storage/progress_store.dart';

class AppProgressController extends ChangeNotifier {
  AppProgressController({
    required List<String> orderedIds,
    ProgressStore? store,
  }) : _orderedIds = List.unmodifiable(orderedIds),
       _store = store ?? MemoryProgressStore();

  final List<String> _orderedIds;
  final ProgressStore _store;
  final Set<String> _completed = {};
  final Map<String, double> _bestScores = {};
  Future<void> _pendingWrite = Future.value();
  bool _disposed = false;
  bool loading = true;
  bool loadFailed = false;
  String? storageError;
  bool beginner = true;
  bool beautify = true;
  bool haptics = true;
  int practiceCount = 0;

  int get totalCount => _orderedIds.length;
  int get completedCount => _completed.length;
  double get fraction => totalCount == 0 ? 0 : completedCount / totalCount;
  double? bestScore(String id) => _bestScores[id];
  bool isCompleted(String id) => _completed.contains(id);
  bool isUnlocked(String id) {
    final index = _orderedIds.indexOf(id);
    return index >= 0 &&
        (index == 0 || _completed.contains(_orderedIds[index - 1]));
  }

  String? get nextId {
    for (final id in _orderedIds) {
      if (!_completed.contains(id)) return id;
    }
    return null;
  }

  bool isNextUp(String id) => nextId == id;

  Future<void> load() async {
    loading = true;
    loadFailed = false;
    storageError = null;
    _notify();
    try {
      final raw = await _store.read();
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        if (data['version'] != 1) {
          throw const FormatException('Unknown version');
        }
        final completed = (data['completed'] as List).cast<String>().toList();
        final scores = (data['scores'] as Map<String, dynamic>).map(
          (id, score) => MapEntry(id, (score as num).clamp(0, 100).toDouble()),
        );
        final settings = data['settings'] as Map<String, dynamic>;
        final loadedBeginner = settings['beginner'] as bool;
        final loadedBeautify = settings['beautify'] as bool;
        final loadedHaptics = settings['haptics'] as bool;
        final count = data['practiceCount'] as int;
        if (count < 0) throw const FormatException('Invalid practice count');
        _completed
          ..clear()
          ..addAll(completed.where(_orderedIds.contains));
        _bestScores
          ..clear()
          ..addAll(scores..removeWhere((id, _) => !_orderedIds.contains(id)));
        beginner = loadedBeginner;
        beautify = loadedBeautify;
        haptics = loadedHaptics;
        practiceCount = count;
      }
    } catch (_) {
      loadFailed = true;
      storageError =
          'Your saved progress could not be opened. Please try again.';
    }
    loading = false;
    _notify();
  }

  Future<void> markCompleted(String id, {double? score}) async {
    if (loading || loadFailed || !isUnlocked(id)) return;
    _completed.add(id);
    practiceCount++;
    if (score != null && score.isFinite) {
      final value = score.clamp(0, 100).toDouble();
      if (value > (_bestScores[id] ?? -1)) _bestScores[id] = value;
    }
    _notify();
    await save();
  }

  Future<void> updateSettings({
    bool? beginner,
    bool? beautify,
    bool? haptics,
  }) async {
    if (loading || loadFailed) return;
    this.beginner = beginner ?? this.beginner;
    this.beautify = beautify ?? this.beautify;
    this.haptics = haptics ?? this.haptics;
    _notify();
    await save();
  }

  Future<void> save() {
    if (loading || loadFailed) return Future.value();
    final snapshot = jsonEncode({
      'version': 1,
      'completed': _completed.toList(),
      'scores': _bestScores,
      'practiceCount': practiceCount,
      'settings': {
        'beginner': beginner,
        'beautify': beautify,
        'haptics': haptics,
      },
    });
    // A slow earlier write must never replace newer progress.
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await _store.write(snapshot);
        storageError = null;
      } catch (_) {
        storageError = 'Changes could not be saved on this device. Tap retry.';
      }
      _notify();
    });
    return _pendingWrite;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
