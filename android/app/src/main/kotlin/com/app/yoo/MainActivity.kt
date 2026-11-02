package com.app.yoo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The only screen of the app. Launched from the "classic" icon; the other
 * icons launch the subclasses below (see AppIcons).
 */
open class MainActivity : FlutterActivity() {

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AppIcons.CHANNEL).setMethodCallHandler {
        call,
        result ->
      when (call.method) {
        "current" -> result.success(AppIcons.current(this))
        "apply" -> {
          val id = call.arguments as? String
          if (id == null || !AppIcons.isKnown(id)) {
            result.error("unknown_icon", "Unknown app icon: $id", null)
            return@setMethodCallHandler
          }
          val changed = AppIcons.apply(this, id)
          result.success(changed)
          // The launcher entry this screen was opened from is now disabled:
          // close cleanly, the user reopens Yoo from the new icon.
          if (changed) finishAndRemoveTask()
        }
        else -> result.notImplemented()
      }
    }
  }
}

// Launcher entries of the other app icons (declared in AndroidManifest.xml).
class IconLightActivity : MainActivity()

class IconDarkActivity : MainActivity()

class IconOceanActivity : MainActivity()

class IconForestActivity : MainActivity()

class IconSunsetActivity : MainActivity()
