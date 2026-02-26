# ProGuard rules for TScan
# Necessary for flutter_secure_storage and other plugins in release mode

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep generic types if needed
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
