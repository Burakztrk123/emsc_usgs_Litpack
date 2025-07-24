# 🌍 Earthquake Monitoring App

A Flutter mobile application that monitors earthquake data from EMSC and USGS APIs with Telegram notification integration and location-based filtering.

## ✨ Features

- **Real-time Earthquake Data**: Fetches earthquake information from both EMSC and USGS APIs
- **Telegram Notifications**: Sends automated notifications for earthquakes within your specified radius
- **Location-based Filtering**: Filter earthquakes by distance from your location and minimum magnitude
- **Interactive Map**: View earthquakes on an interactive map with detailed information
- **Background Monitoring**: Continuous monitoring with background tasks
- **Dual Data Sources**: Combines data from European-Mediterranean Seismological Centre (EMSC) and US Geological Survey (USGS)

## 📱 Screenshots

*Screenshots will be added soon*

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.27.1 or higher)
- Android Studio or VS Code
- Android device or emulator
- Telegram Bot Token (for notifications)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/emsc-usgs-earthquake-app.git
cd emsc-usgs-earthquake-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 🤖 Telegram Bot Setup

1. Open Telegram and search for @BotFather
2. Send `/newbot` command
3. Follow the instructions to create your bot
4. Copy the bot token provided by BotFather
5. Start a conversation with your bot
6. Get your Chat ID by messaging @userinfobot
7. Enter both token and Chat ID in the app's notification settings

## 🔧 Configuration

### Notification Settings
- **Bot Token**: Your Telegram bot token from BotFather
- **Chat ID**: Your Telegram chat ID
- **Notification Radius**: Distance in kilometers for earthquake alerts
- **Minimum Magnitude**: Minimum earthquake magnitude for notifications
- **Location**: Your current location for distance calculations

## 📊 Data Sources

- **EMSC API**: European-Mediterranean Seismological Centre
- **USGS API**: United States Geological Survey

## 🛠️ Built With

- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language
- **HTTP**: API communication
- **Geolocator**: Location services
- **Flutter Map**: Interactive maps
- **WorkManager**: Background tasks
- **Shared Preferences**: Local data storage

## 📋 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  geolocator: ^10.1.1
  permission_handler: ^11.4.0
  shared_preferences: ^2.2.2
  workmanager: ^0.5.2
  flutter_map: ^6.2.1
  latlong2: ^0.9.0
  intl: ^0.18.1
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This app is for informational purposes only. For official earthquake information and emergency alerts, please refer to your local geological survey and emergency services.

## 📞 Support

If you have any questions or issues, please open an issue on GitHub.
