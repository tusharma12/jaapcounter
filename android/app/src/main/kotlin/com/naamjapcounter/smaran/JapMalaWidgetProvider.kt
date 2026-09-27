package com.naamjapcounter.smaran

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Renders the home screen widget from the values the app saved.
 *
 * The widget never starts the Flutter engine: it reads the numbers out of
 * shared preferences, which is why it can be correct the instant the user
 * looks at their home screen.
 */
class JapMalaWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.japmala_widget)

            val mantra = widgetData.getString("mantra", null)
                ?: context.getString(R.string.app_name)
            val beads = widgetData.getInt("beads", 0)
            val malaSize = widgetData.getInt("malaSize", 108).coerceAtLeast(1)
            val todayTotal = widgetData.getInt("todayTotal", 0)
            val todayMalas = widgetData.getInt("todayMalas", 0)
            val streak = widgetData.getInt("streak", 0)

            views.setTextViewText(R.id.widget_mantra, mantra)
            views.setTextViewText(R.id.widget_beads, beads.toString())
            views.setTextViewText(R.id.widget_mala_size, "/ $malaSize")
            views.setProgressBar(
                R.id.widget_progress,
                100,
                (beads * 100 / malaSize).coerceIn(0, 100),
                false,
            )

            val today = context.getString(R.string.widget_today)
            val summary = buildString {
                append("$today  $todayTotal")
                if (todayMalas > 0) append("  ·  $todayMalas×")
                if (streak > 0) append("  ·  🔥 $streak")
            }
            views.setTextViewText(R.id.widget_today, summary)

            // Tapping anywhere on the widget opens the counter.
            val launch = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            views.setOnClickPendingIntent(
                R.id.widget_root,
                PendingIntent.getActivity(
                    context,
                    widgetId,
                    launch,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                ),
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
