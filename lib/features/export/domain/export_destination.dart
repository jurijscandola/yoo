/// Where an exported file goes. The share sheet today (the user saves it or
/// sends it anywhere); Google Drive can implement it later.
abstract interface class ExportDestination {
  /// Delivers a text file named [fileName] with [content].
  Future<void> deliver({required String fileName, required String content, String? subject});
}

/// Destination that discards everything (default before bootstrap).
class NoopExportDestination implements ExportDestination {
  const NoopExportDestination();

  @override
  Future<void> deliver({
    required String fileName,
    required String content,
    String? subject,
  }) async {}
}
