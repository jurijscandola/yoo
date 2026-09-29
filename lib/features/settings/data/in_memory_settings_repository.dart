import 'dart:async';

import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

/// Non-persistent [SettingsRepository], used by tests and as a fallback.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([AppSettings initial = const AppSettings()]) : _current = initial;

  AppSettings _current;
  final _controller = StreamController<AppSettings>.broadcast();

  @override
  Stream<AppSettings> watch() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<AppSettings> load() async => _current;

  @override
  Future<void> save(AppSettings settings) async {
    _current = settings;
    _controller.add(settings);
  }
}
