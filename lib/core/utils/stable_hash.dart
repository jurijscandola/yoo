/// Deterministic 31-bit FNV-1a hash of [input].
///
/// `String.hashCode` is not guaranteed to be stable across runs or isolates,
/// while notification ids and random times must never change for the same key.
int stableHash(String input) {
  var hash = 0x811c9dc5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}
