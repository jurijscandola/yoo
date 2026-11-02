import 'package:flutter/services.dart';

import '../domain/backup_service.dart';

/// [BackupFileSource] backed by the system file picker, through the native
/// channel of MainActivity.
class AndroidBackupFileSource implements BackupFileSource {
  const AndroidBackupFileSource();

  static const _channel = MethodChannel('com.app.yoo/files');

  @override
  bool get isSupported => true;

  @override
  Future<String?> pickText() => _channel.invokeMethod<String>('pickText');
}
