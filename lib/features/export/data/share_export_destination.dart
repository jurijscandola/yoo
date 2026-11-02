import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/export_destination.dart';

/// Writes the file in the app cache and opens the system share sheet, from
/// which the user saves it (Files, Drive…) or sends it.
class ShareExportDestination implements ExportDestination {
  const ShareExportDestination();

  @override
  Future<void> deliver({
    required String fileName,
    required String content,
    String? subject,
    String mimeType = 'text/plain',
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    // Plain text: UTF-8 with BOM so that older editors detect the encoding
    // (✅, accents). Other formats (JSON) stay plain UTF-8.
    final bom = mimeType == 'text/plain' ? const [0xEF, 0xBB, 0xBF] : const <int>[];
    await file.writeAsBytes([...bom, ...utf8.encode(content)], flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        subject: subject,
      ),
    );
  }
}
