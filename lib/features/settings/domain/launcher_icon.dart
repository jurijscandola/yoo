/// The icon the device launcher shows for Yoo.
///
/// Android switches between launcher entries (see AppIcons.kt); iOS needs
/// alternate icons set up from a Mac, so it is not supported yet.
abstract interface class LauncherIcon {
  /// Whether the launcher icon can be changed on this device.
  bool get isSupported;

  /// Id of the icon the launcher shows (an `AppIconOption.id`), or `null`
  /// when unknown.
  Future<String?> current();

  /// Corner radius of the device's icon shape, as a share of the side (0.5
  /// for a circle), or `null` when unknown. The system splash screen shows
  /// the icon with this shape.
  Future<double?> maskCorner();

  /// Switches the launcher icon to [id]. On Android the app closes right
  /// after, as the launcher entry it was opened from is replaced. Returns
  /// whether the icon changed.
  Future<bool> apply(String id);
}

/// Devices (and tests) where only the in-app logo follows the choice.
class UnsupportedLauncherIcon implements LauncherIcon {
  const UnsupportedLauncherIcon();

  @override
  bool get isSupported => false;

  @override
  Future<String?> current() async => null;

  @override
  Future<double?> maskCorner() async => null;

  @override
  Future<bool> apply(String id) async => false;
}
