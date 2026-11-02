package com.app.yoo

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import com.app.yoo.widget.YooWidgetReceiver

/**
 * Switches the launcher icon. Each icon is a launcher activity of its own
 * (MainActivity for "classic"); exactly one is enabled at a time. The ids are
 * the ones of AppIconOption in lib/core/widgets/yoo_icon.dart.
 *
 * Launchers usually remove a home screen shortcut whose activity gets
 * disabled: the user adds the new icon again from the app drawer.
 */
object AppIcons {
  const val CHANNEL = "com.app.yoo/app_icon"

  private val activities =
      linkedMapOf(
          "classic" to MainActivity::class.java,
          "light" to IconLightActivity::class.java,
          "dark" to IconDarkActivity::class.java,
          "ocean" to IconOceanActivity::class.java,
          "forest" to IconForestActivity::class.java,
          "sunset" to IconSunsetActivity::class.java,
      )

  fun isKnown(id: String) = activities.containsKey(id)

  /** The icon whose launcher entry is enabled ("classic" if none is). */
  fun current(context: Context): String =
      activities.entries.firstOrNull { isEnabled(context, it.value) }?.key ?: "classic"

  /**
   * Enables the launcher entry of [id] and disables the others. Returns
   * whether something changed. The new entry is enabled first, so there is
   * never a moment without an icon.
   */
  fun apply(context: Context, id: String): Boolean {
    val target = activities[id] ?: return false
    if (current(context) == id && activities.values.count { isEnabled(context, it) } == 1) {
      return false
    }
    val pm = context.packageManager
    pm.setComponentEnabledSetting(
        ComponentName(context, target),
        PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
        PackageManager.DONT_KILL_APP,
    )
    for (other in activities.values) {
      if (other == target) continue
      pm.setComponentEnabledSetting(
          ComponentName(context, other),
          PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
          PackageManager.DONT_KILL_APP,
      )
    }
    redrawWidgets(context)
    return true
  }

  private fun isEnabled(context: Context, activity: Class<*>): Boolean {
    val component = ComponentName(context, activity)
    return when (context.packageManager.getComponentEnabledSetting(component)) {
      PackageManager.COMPONENT_ENABLED_STATE_ENABLED -> true
      PackageManager.COMPONENT_ENABLED_STATE_DEFAULT ->
          // As declared in the manifest.
          context.packageManager
              .getActivityInfo(component, PackageManager.MATCH_DISABLED_COMPONENTS)
              .enabled
      else -> false
    }
  }

  /** The widget header opens the enabled launcher entry: redraw it. */
  private fun redrawWidgets(context: Context) {
    val manager = AppWidgetManager.getInstance(context)
    val ids = manager.getAppWidgetIds(ComponentName(context, YooWidgetReceiver::class.java))
    if (ids.isEmpty()) return
    context.sendBroadcast(
        Intent(context, YooWidgetReceiver::class.java)
            .setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
            .putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
    )
  }
}
