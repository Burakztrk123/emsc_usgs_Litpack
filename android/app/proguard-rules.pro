# Flutter ProGuard Rules for Earthquake Tracker App

# Keep Flutter Engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep SQLite
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Keep HTTP client
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Keep JSON serialization
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Keep location services
-keep class com.google.android.gms.location.** { *; }
-keep class com.google.android.gms.maps.** { *; }

# Keep notification services
-keep class com.google.firebase.messaging.** { *; }

# Keep WebView
-keep class android.webkit.** { *; }

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Optimize enums
-optimizations !code/simplification/enum

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom exceptions
-keep public class * extends java.lang.Exception

# Keep R class
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Earthquake Tracker specific rules
-keep class com.yourcompany.earthquaketracker.** { *; }

# Keep model classes (if using reflection)
-keep class * extends java.lang.Object {
    public <fields>;
    public <methods>;
}
