# flutter_local_notifications serialises scheduled notifications with Gson.
-keep class com.dexterous.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
-dontwarn com.dexterous.**

# The home screen widget provider is referenced only from the manifest.
-keep class com.japmala.japmala.JapMalaWidgetProvider { *; }
