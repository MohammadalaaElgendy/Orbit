# Drift / SQLite rules
-keep class net.sqlcipher.** { *; }
-keep class sqlite3.** { *; }
-keep class org.sqlite.** { *; }
-keep class com.mohammad.alaa.orbit.core.data.database.** { *; }

# Keep Flutter and Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Google Fonts / Inter / Manrope
-keep class com.google.fonts.** { *; }

# Play Core (Fixes build error with R8)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.common.annotation.KeepName
