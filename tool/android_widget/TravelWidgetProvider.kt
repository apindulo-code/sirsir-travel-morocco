package ma.sirsirtravel.morocco.limited

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Native renderer; Flutter foreground/background services own the data. */
class TravelWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_travel).apply {
                setTextViewText(R.id.widget_city, widgetData.getString("weather_city", "المغرب") ?: "المغرب")
                setTextViewText(R.id.widget_temperature, widgetData.getString("weather_temperature", "--°C") ?: "--°C")
                setTextViewText(R.id.widget_condition, widgetData.getString("weather_condition", "افتح التطبيق للتحديث") ?: "افتح التطبيق للتحديث")
                setTextViewText(R.id.widget_wind, "الرياح: " + (widgetData.getString("weather_wind", "--") ?: "--"))
                setTextViewText(R.id.widget_updated_at, widgetData.getString("weather_updated_at", "لم يتم التحديث بعد") ?: "لم يتم التحديث بعد")
                val launchIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, launchIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
