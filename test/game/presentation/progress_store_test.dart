import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:swipeout_last_train/game/data/progress_repository.dart';
import 'package:swipeout_last_train/game/domain/city.dart';
import 'package:swipeout_last_train/game/domain/control_action.dart';
import 'package:swipeout_last_train/game/domain/level_definition.dart';
import 'package:swipeout_last_train/game/domain/level_result.dart';
import 'package:swipeout_last_train/game/domain/progress.dart';
import 'package:swipeout_last_train/game/presentation/game/progress_store.dart';

import '../../support/graph_builders.dart';
import '../../support/memory_progress_repository.dart';

ProgressStore _store({
  Progress progress = const Progress(),
  Map<CityId, List<LevelDefinition>>? catalog,
}) => ProgressStore(
  catalog:
      catalog ??
      {
        CityId.ankara: [ank01(), ank02()],
      },
  repository: MemoryProgressRepository(progress),
  progress: progress,
  clock: () => DateTime.utc(2026, 11, 5),
);

LevelResult _won(String id) =>
    LevelResult(levelId: id, pulses: 2, rating: null);

void main() {
  test(
    'the first level of a city is open, the next opens once solved',
    () async {
      final store = _store();
      expect(store.isUnlocked(ank01()), isTrue);
      expect(store.isUnlocked(ank02()), isFalse);

      await store.recordWin(_won('ANK-01'));
      expect(store.isUnlocked(store.levelById('ANK-02')!), isTrue);
    },
  );

  test(
    'continue goes to the saved run, else the first unsolved level',
    () async {
      final store = _store();
      expect(store.continueTarget()!.level.id, 'ANK-01');

      await store.recordWin(_won('ANK-01'));
      expect(store.continueTarget()!.level.id, 'ANK-02');

      await store.saveRun('ANK-01', const [null]);
      final target = store.continueTarget()!;
      expect(target.level.id, 'ANK-01');
      expect(target.actions, const [null]);
    },
  );

  test('a win is stored, clears the saved run and is persisted', () async {
    final repo = MemoryProgressRepository();
    final store = ProgressStore(
      catalog: {
        CityId.ankara: [ank01(), ank02()],
      },
      repository: repo,
      progress: const Progress(),
    );
    await store.saveRun('ANK-01', const [ToggleSwitch('B')]);
    await store.recordWin(_won('ANK-01'));

    expect(repo.stored.isSolved('ANK-01'), isTrue);
    expect(repo.stored.run, isNull);
  });

  test('an empty run clears the saved run', () async {
    final store = _store();
    await store.saveRun('ANK-01', const [null]);
    await store.saveRun('ANK-01', const []);
    expect(store.progress.run, isNull);
  });

  test('completing a six-level city reports its new stamp once', () async {
    final six = [
      for (var i = 1; i <= 6; i++)
        buildLevel(
          id: 'BAK-0$i',
          number: i,
          nodes: const [],
          edges: const [],
          trains: const [],
        ),
    ];
    final store = _store(catalog: {CityId.baku: six});
    for (final level in six.take(5)) {
      expect(await store.recordWin(_won(level.id)), isEmpty);
    }
    expect(await store.recordWin(_won('BAK-06')), [CityId.baku]);
    expect(
      store.passport.stampFor(CityId.baku).earnedOn,
      DateTime.utc(2026, 11, 5),
    );
    expect(await store.recordWin(_won('BAK-06')), isEmpty);
  });

  test(
    'a failing disk write keeps the progress in memory, never throws',
    () async {
      final store = ProgressStore(
        catalog: {
          CityId.ankara: [ank01(), ank02()],
        },
        repository: _FailingRepository(),
        progress: const Progress(),
      );
      await store.saveRun('ANK-01', const [null]);
      expect(store.progress.run!.levelId, 'ANK-01');
      await store.recordWin(
        const LevelResult(levelId: 'ANK-01', pulses: 2, rating: null),
      );
      expect(store.progress.isSolved('ANK-01'), isTrue);
    },
  );
}

final class _FailingRepository implements ProgressRepository {
  @override
  Future<Progress> load() async => const Progress();

  @override
  Future<void> save(Progress progress) async =>
      throw const FileSystemException('disk full');
}
