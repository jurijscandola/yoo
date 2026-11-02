import 'package:flutter/services.dart';

import '../domain/launcher_icon.dart';

/// [LauncherIcon] backed by the native channel of MainActivity (AppIcons.kt).
class AndroidLauncherIcon implements LauncherIcon {
  const AndroidLauncherIcon();

  static const _channel = MethodChannel('com.app.yoo/app_icon');

  @override
  bool get isSupported => true;

  @override
  Future<String?> current() => _channel.invokeMethod<String>('current');

  @override
  Future<double?> maskCorner() => _channel.invokeMethod<double>('maskCorner');

  @override
  Future<bool> apply(String id) async => await _channel.invokeMethod<bool>('apply', id) ?? false;
}
