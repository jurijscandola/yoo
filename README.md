# Yoo

Minimal app for small recurring activities with reliable local reminders (Android & iOS).

- Architecture and product decisions: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Code generation (Drift): `dart run build_runner build`
- Tests: `flutter test`
- Android build/run: `flutter build apk --debug` / `flutter run`. Keep the project path free of
  `!`: the Gradle wrapper cannot load its jar from such a path.
