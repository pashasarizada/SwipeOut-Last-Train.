import '../domain/progress.dart';

/// Where progress lives. Screens depend on this, not on storage (DIP).
abstract interface class ProgressRepository {
  Future<Progress> load();
  Future<void> save(Progress progress);
}
