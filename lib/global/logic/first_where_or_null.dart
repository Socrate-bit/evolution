extension ExtendedList on List {
  /// The first entry satisfying test, or null if there are none.
  dynamic firstWhereOrNull(bool Function(dynamic entry) test) {
   for (var entry in this) {
    if (test(entry)) return entry;
  }
  return null;
  }
}

extension ExtendedMap on Map {
  /// The first entry satisfying test, or null if there are none.
  MapEntry? firstWhereOrNull(bool Function(MapEntry entry) test) {
    for (var entry in this.entries) {
      if (test(entry)) return entry;
    }
    return null;
  }
}