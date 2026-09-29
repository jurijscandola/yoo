# Yoo

Minimal app for small recurring activities with reliable local reminders (Android & iOS).

- Architecture and product decisions: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Code generation (Drift): `dart run build_runner build`
- Tests: `flutter test`
- Android build/run: the project path contains `!`, which breaks the Gradle wrapper.
  Use `powershell -File tool/flutter_android.ps1 run` (it maps the folder to drive `Y:`).
