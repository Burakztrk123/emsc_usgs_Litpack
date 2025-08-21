# Native Code Declaration for Google Play Store

## Native Libraries Used

This Flutter application contains the following native code components:

### Flutter Framework Native Components:
- **Flutter Engine** (C++): Core rendering and platform communication
- **Dart VM** (C++): Dart runtime execution
- **Skia Graphics** (C++): 2D graphics rendering

### Third-Party Native Dependencies:
- **SQLite** (C): Local database operations
- **Geolocator** (Platform-specific): GPS and location services
- **HTTP Client** (Platform-specific): Network communications
- **Flutter Map** (Platform-specific): Map rendering and tile loading

### Platform-Specific Native Code:
- **Android**: Java/Kotlin platform channels for system integration
- **iOS**: Objective-C/Swift platform channels for system integration

### Security Measures:
- Code obfuscation enabled via R8/ProGuard
- No custom native code written by developer
- All native components are from verified Flutter ecosystem

### Data Processing:
- Location data processing for earthquake proximity calculations
- JSON parsing for USGS API responses
- SQLite operations for local caching

This application does NOT contain:
- Custom C/C++ code
- Custom JNI implementations
- Cryptocurrency mining code
- Malicious or harmful native code

All native code is standard Flutter framework components and verified third-party packages from pub.dev.
