package com.app.yoo.widget

import android.content.Context
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.ContentScale
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import com.app.yoo.MainActivity
import com.app.yoo.R
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver
import es.antonborri.home_widget.actionStartActivity
import java.time.LocalDate
import org.json.JSONObject

/**
 * Home screen widget: today's date and the activities still to do, in the
 * colors and card style of the user's theme.
 *
 * The data is a JSON snapshot written by the app (lib/features/home_widget/)
 * under [DATA_KEY]. It holds today and tomorrow, so at midnight (a redraw is
 * scheduled by the app) the widget shows the new day without running Dart.
 * Tapping a card completes the activity in background (Dart callback, same
 * logic as the notification actions); tapping the header opens Home.
 */
class YooWidget : GlanceAppWidget() {

  override val stateDefinition = HomeWidgetGlanceStateDefinition()

  override suspend fun provideGlance(context: Context, id: GlanceId) {
    provideContent { Content(context, currentState()) }
  }

  @Composable
  private fun Content(context: Context, state: HomeWidgetGlanceState) {
    val snapshot = Snapshot.parse(state.preferences.getString(DATA_KEY, null))
    val colors = snapshot?.colors ?: Colors.FALLBACK
    val day = snapshot?.days?.firstOrNull { it.date == LocalDate.now().toString() }
    val openHome = actionStartActivity<MainActivity>(context, Uri.parse("yoo://home"))

    Column(
        modifier =
            GlanceModifier.fillMaxSize()
                .background(colors.page)
                .cornerRadius(20.dp)
                .padding(10.dp),
    ) {
      // Header: opens the app on Home.
      Column(
          modifier =
              GlanceModifier.fillMaxWidth()
                  .background(colors.surface)
                  .cornerRadius(14.dp)
                  .padding(horizontal = 14.dp, vertical = 10.dp)
                  .clickable(openHome),
      ) {
        Text(
            day?.title ?: "Yoo",
            style = TextStyle(color = ColorProvider(colors.accent), fontSize = 12.sp, fontWeight = FontWeight.Bold),
        )
        Text(
            day?.subtitle ?: snapshot?.staleText ?: "Yoo",
            maxLines = 1,
            style = TextStyle(color = ColorProvider(colors.text), fontSize = 16.sp, fontWeight = FontWeight.Bold),
        )
      }
      Spacer(GlanceModifier.height(8.dp))

      when {
        day == null ->
            Message(snapshot?.staleText ?: "", colors, GlanceModifier.clickable(openHome))
        day.items.isEmpty() -> Message(day.emptyText, colors, GlanceModifier.clickable(openHome))
        else ->
            LazyColumn(modifier = GlanceModifier.fillMaxSize()) {
              items(day.items, itemId = { it.activityId.hashCode().toLong() }) { item ->
                Column {
                  ItemCard(
                      item,
                      day.date,
                      colors,
                      snapshot?.cardStyle ?: CardStyle.STANDARD,
                      snapshot?.textScale ?: 1f,
                  )
                  // Notebook lines follow one another; cards are spaced.
                  if (snapshot?.cardStyle != CardStyle.PAPER) Spacer(GlanceModifier.height(6.dp))
                }
              }
            }
      }
    }
  }

  @Composable
  private fun Message(text: String, colors: Colors, modifier: GlanceModifier) {
    Box(
        modifier = modifier.fillMaxSize().padding(8.dp),
        contentAlignment = Alignment.Center,
    ) {
      Text(text, style = TextStyle(color = ColorProvider(colors.textMuted), fontSize = 14.sp))
    }
  }

  /**
   * An activity in the user's card style (see CardStyle in app_settings.dart).
   *
   * Glance has no borders, shadows or gradient strokes, so they are imitated
   * with an outer box: a solid one for the border, a tinted fade
   * (widget_fade_up) for the half border and the colored shadow.
   */
  @Composable
  private fun ItemCard(item: Item, date: String, colors: Colors, style: String, textScale: Float) {
    val link =
        Uri.Builder()
            .scheme("yoo")
            .authority("complete")
            .appendQueryParameter("activity", item.activityId)
            .appendQueryParameter("date", date)
            .appendQueryParameter("action", item.action)
            .build()
            .toString()
    val complete = actionRunCallback<CompleteActivityAction>(actionParametersOf(LINK to link))

    if (style == CardStyle.PAPER) {
      PaperRow(item, colors, textScale, GlanceModifier.clickable(complete))
      return
    }

    val fade = ImageProvider(R.drawable.widget_fade_up)
    val outer =
        when (style) {
          CardStyle.ONLY_BUTTON ->
              GlanceModifier.fillMaxWidth()
                  .background(colors.text.copy(alpha = 0.07f))
                  .cornerRadius(12.dp)
                  .padding(bottom = 2.dp)
          CardStyle.COLORED_SHADOW ->
              GlanceModifier.fillMaxWidth()
                  .background(
                      fade,
                      ContentScale.FillBounds,
                      ColorFilter.tint(ColorProvider(item.border.copy(alpha = 0.45f))),
                  )
                  .padding(start = 1.dp, end = 1.dp, bottom = 4.dp)
          CardStyle.HALF_BORDER ->
              GlanceModifier.fillMaxWidth()
                  .background(fade, ContentScale.FillBounds, ColorFilter.tint(ColorProvider(item.border)))
                  .padding(2.dp)
          else -> GlanceModifier.fillMaxWidth().background(item.border).cornerRadius(12.dp).padding(2.dp)
        }
    Box(modifier = outer.clickable(complete)) {
      Row(
          modifier =
              GlanceModifier.fillMaxWidth()
                  .background(colors.card)
                  .cornerRadius(10.dp)
                  .padding(horizontal = 12.dp, vertical = 9.dp),
          verticalAlignment = Alignment.CenterVertically,
      ) {
        // The completion button on the left, as in the app.
        CheckFace(item.border, square = false, size = 17.dp)
        Spacer(GlanceModifier.width(10.dp))
        Column(modifier = GlanceModifier.defaultWeight()) { ItemTexts(item, colors, textScale) }
      }
    }
  }

  /** Notebook style: a ruled line, the check square in the red-lined margin. */
  @Composable
  private fun PaperRow(item: Item, colors: Colors, textScale: Float, modifier: GlanceModifier) {
    Column(modifier = modifier.fillMaxWidth()) {
      Row(
          modifier = GlanceModifier.fillMaxWidth().padding(vertical = 7.dp),
          verticalAlignment = Alignment.CenterVertically,
      ) {
        Box(modifier = GlanceModifier.width(38.dp), contentAlignment = Alignment.Center) {
          CheckFace(item.border, square = true, size = 22.dp)
        }
        Box(modifier = GlanceModifier.width(1.dp).fillMaxHeight().background(PAPER_MARGIN)) {}
        Spacer(GlanceModifier.width(10.dp))
        Column(modifier = GlanceModifier.defaultWeight()) { ItemTexts(item, colors, textScale) }
      }
      Box(modifier = GlanceModifier.fillMaxWidth().height(1.dp).background(PAPER_RULE)) {}
    }
  }

  @Composable
  private fun ItemTexts(item: Item, colors: Colors, textScale: Float) {
    Text(
        item.name,
        maxLines = 1,
        style =
            TextStyle(
                color = ColorProvider(colors.text),
                fontSize = (14 * textScale).sp,
                fontWeight = FontWeight.Medium,
            ),
    )
    item.detail?.let {
      Text(it, style = TextStyle(color = ColorProvider(colors.textMuted), fontSize = (12 * textScale).sp))
    }
  }

  /** The completion button: a light tint and the colored outline, empty until done. */
  @Composable
  private fun CheckFace(color: Color, square: Boolean, size: Dp) {
    Box(modifier = GlanceModifier.size(size), contentAlignment = Alignment.Center) {
      Image(
          provider =
              ImageProvider(if (square) R.drawable.widget_check_square_fill else R.drawable.widget_check_ring_fill),
          contentDescription = null,
          colorFilter = ColorFilter.tint(ColorProvider(color.copy(alpha = 0.07f))),
          modifier = GlanceModifier.size(size),
      )
      Image(
          provider = ImageProvider(if (square) R.drawable.widget_check_square else R.drawable.widget_check_ring),
          contentDescription = null,
          colorFilter = ColorFilter.tint(ColorProvider(color)),
          modifier = GlanceModifier.size(size),
      )
    }
  }

  companion object {
    /** Key of the snapshot written by AndroidHomeScreenWidget (Dart). */
    const val DATA_KEY = "yoo_widget"

    /** Notebook ruling and margin line (same as the app's paper style). */
    val PAPER_RULE = Color(0x736E9BD1)
    val PAPER_MARGIN = Color(0x8CD9606A)

    val LINK = ActionParameters.Key<String>("link")
  }
}

/** Completes the tapped activity through the Dart interactivity callback. */
class CompleteActivityAction : ActionCallback {
  override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
    val link = parameters[YooWidget.LINK] ?: return
    HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse(link)).send()
  }
}

class YooWidgetReceiver : HomeWidgetGlanceWidgetReceiver<YooWidget>() {
  override val glanceAppWidget = YooWidget()
}

// ---------------------------------------------------------------------------
// Snapshot (see lib/features/home_widget/domain/widget_snapshot.dart)
// ---------------------------------------------------------------------------

internal data class Colors(
    val page: Color,
    val surface: Color,
    val card: Color,
    val text: Color,
    val textMuted: Color,
    val accent: Color,
) {
  companion object {
    /** The default "paper" theme, used before the app wrote a snapshot. */
    val FALLBACK =
        Colors(
            page = Color(0xFFECE9E2),
            surface = Color(0xFFFAF8F4),
            card = Color(0xFFFAF8F4),
            text = Color(0xFF1E1D1B),
            textMuted = Color(0x8C1E1D1B),
            accent = Color(0xFF1E1D1B),
        )
  }
}

/** Names of CardStyle in app_settings.dart. */
internal object CardStyle {
  const val STANDARD = "standard"
  const val ONLY_BUTTON = "onlyButton"
  const val COLORED_SHADOW = "coloredShadow"
  const val HALF_BORDER = "halfBorder"
  const val PAPER = "paper"
}

internal data class Item(
    val activityId: String,
    val name: String,
    val detail: String?,
    val border: Color,
    val action: String,
)

internal data class Day(
    val date: String,
    val title: String,
    val subtitle: String,
    val emptyText: String,
    val items: List<Item>,
)

internal data class Snapshot(
    val colors: Colors,
    val days: List<Day>,
    val staleText: String,
    val cardStyle: String,
    val textScale: Float,
) {
  companion object {
    fun parse(raw: String?): Snapshot? {
      if (raw == null) return null
      return try {
        val json = JSONObject(raw)
        val c = json.getJSONObject("colors")
        fun color(key: String) = Color(c.getLong(key).toInt())
        val colors =
            Colors(
                page = color("page"),
                surface = color("surface"),
                card = color("card"),
                text = color("text"),
                textMuted = color("textMuted"),
                accent = color("accent"),
            )
        val days = json.getJSONArray("days")
        Snapshot(
            colors = colors,
            days =
                (0 until days.length()).map { i ->
                  val d = days.getJSONObject(i)
                  val items = d.getJSONArray("items")
                  Day(
                      date = d.getString("date"),
                      title = d.getString("title"),
                      subtitle = d.getString("subtitle"),
                      emptyText = d.getString("emptyText"),
                      items =
                          (0 until items.length()).map { j ->
                            val it = items.getJSONObject(j)
                            Item(
                                activityId = it.getString("activityId"),
                                name = it.getString("name"),
                                detail = if (it.isNull("detail")) null else it.getString("detail"),
                                border = Color(it.getLong("borderColor").toInt()),
                                action = it.getString("action"),
                            )
                          },
                  )
                },
            staleText = json.getString("staleText"),
            // Snapshots written before card styles existed: the classic cards.
            cardStyle = json.optString("cardStyle", CardStyle.STANDARD),
            textScale = json.optDouble("textScale", 1.0).toFloat(),
        )
      } catch (e: Exception) {
        null
      }
    }
  }
}
