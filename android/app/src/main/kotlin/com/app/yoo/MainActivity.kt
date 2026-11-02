package com.app.yoo

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * The only screen of the app. Launched from the "classic" icon; the other
 * icons launch the subclasses below (see AppIcons).
 */
open class MainActivity : FlutterActivity() {

  /// Waiting for the file picker opened by "pickText".
  private var pendingPick: MethodChannel.Result? = null

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    // Backups to import: the system file picker, returning the file's text.
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FILES_CHANNEL).setMethodCallHandler {
        call,
        result ->
      if (call.method != "pickText") return@setMethodCallHandler result.notImplemented()
      if (pendingPick != null) return@setMethodCallHandler result.error("busy", null, null)
      pendingPick = result
      val intent =
          Intent(Intent.ACTION_OPEN_DOCUMENT).addCategory(Intent.CATEGORY_OPENABLE).setType("*/*")
      @Suppress("DEPRECATION") startActivityForResult(intent, PICK_TEXT_REQUEST)
    }
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

  @Deprecated("Deprecated in Java")
  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    if (requestCode != PICK_TEXT_REQUEST) {
      @Suppress("DEPRECATION") super.onActivityResult(requestCode, resultCode, data)
      return
    }
    val result = pendingPick ?: return
    pendingPick = null
    val uri = data?.data
    if (resultCode != RESULT_OK || uri == null) {
      result.success(null)
      return
    }
    // Read off the main thread; backups are small, but storage can be slow.
    Thread {
          try {
            val bytes =
                contentResolver.openInputStream(uri)?.use { input ->
                  input.readBytes().also {
                    require(it.size <= MAX_PICK_BYTES) { "File too large" }
                  }
                }
            runOnUiThread { result.success(bytes?.toString(Charsets.UTF_8)) }
          } catch (e: Exception) {
            runOnUiThread { result.error("read_failed", e.message, null) }
          }
        }
        .start()
  }

  companion object {
    private const val FILES_CHANNEL = "com.app.yoo/files"
    private const val PICK_TEXT_REQUEST = 4127
    private const val MAX_PICK_BYTES = 50 * 1024 * 1024
  }
}

// Launcher entries of the other app icons (declared in AndroidManifest.xml).
class IconLightActivity : MainActivity()

class IconDarkActivity : MainActivity()

class IconOceanActivity : MainActivity()

class IconForestActivity : MainActivity()

class IconSunsetActivity : MainActivity()
