package ma.sirsirtravel.morocco.limited

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Native Android renderer for the SirSir weather home-screen widget.
 * Weather values are written by Flutter through the home_widget plugin.
 */
class TravelWeatherWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.widget_weather
            ).apply {
                setTextViewText(
                    R.id.widget_city,
                    widgetData.getString("weather_city", "المغرب") ?: "المغرب"
                )
                setTextViewText(
                    R.id.widget_temperature,
                    widgetData.getString("weather_temperature", "--°C") ?: "--°C"
                )
                setTextViewText(
                    R.id.widget_condition,
                    widgetData.getString("weather_condition", "افتح التطبيق للتحديث")
                        ?: "افتح التطبيق للتحديث"
                )
                setTextViewText(
                    R.id.widget_wind,
                    "الرياح: " + (widgetData.getString("weather_wind", "--") ?: "--")
                )
                setTextViewText(
                    R.id.widget_updated_at,
                    widgetData.getString("weather_updated_at", "لم يتم التحديث بعد")
                        ?: "لم يتم التحديث بعد"
                )

                // Tapping the widget opens SirSir; it does not start a second
                // weather implementation or request location in the background.
                val launchIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_root, launchIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
