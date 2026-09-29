/// Font families offered in Personalization. `null` is the platform font.
/// The files are bundled in `assets/fonts` (see pubspec.yaml).
abstract final class YooFonts {
  static const options = <String?>[null, 'Inter', 'Nunito', 'Lora', 'JetBrains Mono'];

  /// Bundled fonts with their license file, for the license page.
  static const licenses = {
    'Inter': 'assets/fonts/Inter-OFL.txt',
    'Nunito': 'assets/fonts/Nunito-OFL.txt',
    'Lora': 'assets/fonts/Lora-OFL.txt',
    'JetBrains Mono': 'assets/fonts/JetBrainsMono-OFL.txt',
  };
}
