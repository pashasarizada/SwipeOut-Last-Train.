/// Unbounded last-in, first-out history.
final class UndoHistory<T> {
  final List<T> _items = [];

  int get length => _items.length;
  bool get canUndo => _items.isNotEmpty;

  void push(T value) => _items.add(value);

  T? pop() => _items.isEmpty ? null : _items.removeLast();

  void clear() => _items.clear();
}
