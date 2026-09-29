# Yoo

Minimal app for small recurring activities with reliable local reminders (Android & iOS).

- Architecture and product decisions: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
- Code generation (Drift): `dart run build_runner build`
- Tests: `flutter test` (includes a large-text layout check in `test/polish/`)
- Android build/run: `flutter build apk --debug` / `flutter run`. Keep the project path free of
  `!`: the Gradle wrapper cannot load its jar from such a path.
- Placeholder icons: `python tool/generate_placeholder_icons.py` (needs Pillow).
- Status and open items: see "Current status" in the architecture document.
