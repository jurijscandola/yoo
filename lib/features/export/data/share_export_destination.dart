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
  Future<void> deliver({required String fileName, required String content, String? subject}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$fileName');
    // UTF-8 with BOM so that older editors detect the encoding (✅, accents).
    await file.writeAsBytes([0xEF, 0xBB, 0xBF, ...utf8.encode(content)], flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'text/plain')],
        subject: subject,
      ),
    );
  }
}
