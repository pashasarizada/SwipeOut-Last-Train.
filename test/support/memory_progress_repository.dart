import 'package:swipeout_last_train/game/data/progress_repository.dart';
import 'package:swipeout_last_train/game/domain/progress.dart';

final class MemoryProgressRepository implements ProgressRepository {
  MemoryProgressRepository([this.stored = const Progress()]);

  Progress stored;
  int saves = 0;

  @override
  Future<Progress> load() async => stored;

  @override
  Future<void> save(Progress progress) async {
    stored = progress;
    saves++;
  }
}
