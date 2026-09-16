import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/src/controllers/app_progress_controller.dart';
import 'package:learn_uigarjin/src/storage/progress_store.dart';

class FailingStore extends MemoryProgressStore {
  bool fail = true;
  @override
  Future<void> write(String value) async {
    if (fail) throw StateError('Disk unavailable');
    await super.write(value);
  }
}

void main() {
  AppProgressController create(ProgressStore store) =>
      AppProgressController(orderedIds: ['a', 'b', 'c'], store: store);

  test('restart restores progress, personal bests, and settings', () async {
    final store = MemoryProgressStore();
    final first = create(store);
    await first.load();
    await first.markCompleted('a', score: 91);
    await first.markCompleted('a', score: 70);
    await first.updateSettings(
      beginner: false,
      beautify: false,
      haptics: false,
    );
    first.dispose();
    final restored = create(store);
    await restored.load();
    expect(restored.completedCount, 1);
    expect(restored.practiceCount, 2);
    expect(restored.bestScore('a'), 91);
    expect(restored.isUnlocked('b'), isTrue);
    expect(restored.isUnlocked('c'), isFalse);
    expect(restored.nextId, 'b');
    expect(restored.beginner, isFalse);
    expect(restored.beautify, isFalse);
    expect(restored.haptics, isFalse);
    restored.dispose();
  });

  test('unknown or locked letters cannot change progress', () async {
    final progress = create(MemoryProgressStore());
    await progress.load();
    await progress.markCompleted('unknown');
    await progress.markCompleted('c');
    expect(progress.isUnlocked('unknown'), isFalse);
    expect(progress.completedCount, 0);
    expect(progress.practiceCount, 0);
    progress.dispose();
  });

  test(
    'corrupt storage is preserved and cannot be silently overwritten',
    () async {
      final store = MemoryProgressStore()..value = '{bad data';
      final progress = create(store);
      await progress.load();
      expect(progress.loadFailed, isTrue);
      await progress.markCompleted('a');
      await progress.updateSettings(beautify: false);
      await progress.save();
      expect(store.value, '{bad data');
      expect(progress.completedCount, 0);
      progress.dispose();
    },
  );

  test('failed writes retain session progress and retry saves it', () async {
    final store = FailingStore();
    final progress = create(store);
    await progress.load();
    await progress.markCompleted('a', score: 88);
    expect(progress.storageError, isNotNull);
    expect(progress.isCompleted('a'), isTrue);
    store.fail = false;
    await progress.save();
    expect(progress.storageError, isNull);
    final restored = create(store);
    await restored.load();
    expect(restored.bestScore('a'), 88);
    progress.dispose();
    restored.dispose();
  });

  test('rapid changes persist the newest snapshot', () async {
    final store = MemoryProgressStore();
    final progress = create(store);
    await progress.load();
    await Future.wait([
      progress.markCompleted('a'),
      progress.updateSettings(beautify: false),
      progress.markCompleted('b'),
    ]);
    final restored = create(store);
    await restored.load();
    expect(restored.completedCount, 2);
    expect(restored.beautify, isFalse);
    progress.dispose();
    restored.dispose();
  });
}
