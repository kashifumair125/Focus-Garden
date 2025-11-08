# 🌱 Focus Garden

A beautiful gamified focus timer app that helps you stay productive while growing your virtual garden. Complete focus sessions to unlock and collect various plants!

## ✨ Features

- **⏱️ Focus Timer**: Customizable timer to help you concentrate on tasks
- **🌿 Plant Rewards**: Unlock beautiful plants by completing focus sessions
- **🏡 Virtual Garden**: Display and admire your collected plants
- **📊 Statistics**: Track your focus sessions and productivity over time
- **🎨 Beautiful UI**: Clean, nature-inspired design with smooth animations
- **💾 Local Storage**: All your data is stored locally on your device
- **🔊 Audio Feedback**: Sound notifications when sessions complete

## 🌸 Plant Collection

Grow your garden by completing focus sessions of different durations:
- **Daisy** - Quick focus sessions
- **Rose** - Medium focus sessions
- **Oak Tree** - Long focus sessions

The longer you focus, the more rare plants you can unlock!

## 🚀 Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (SDK 3.1.0 or higher)
- Dart 3.1.0 or higher

### Installation

1. Clone the repository:
```bash
git clone https://github.com/kashifumair125/Focus-Garden.git
cd Focus-Garden
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters (for data models):
```bash
flutter pub run build_runner build
```

4. Run the app:
```bash
flutter run
```

## 🏗️ Built With

- **[Flutter](https://flutter.dev/)** - Cross-platform UI framework
- **[Riverpod](https://riverpod.dev/)** - State management
- **[Hive](https://docs.hivedb.dev/)** - Fast, lightweight local database
- **[Lottie](https://pub.dev/packages/lottie)** - Beautiful animations

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── plant.dart
│   └── focus_session.dart
├── screens/                  # UI screens
│   ├── timer_screen.dart
│   ├── garden_screen.dart
│   ├── stats_screen.dart
│   └── main_navigation.dart
├── services/                 # Business logic
│   ├── timer_service.dart
│   ├── storage_service.dart
│   ├── reward_service.dart
│   └── audio_service.dart
└── widgets/                  # Reusable UI components
    ├── plant_widget.dart
    ├── circular_timer.dart
    ├── timer_controls.dart
    ├── duration_selector.dart
    ├── reward_popup.dart
    └── enhanced_ui.dart
```

## 🎯 How It Works

1. **Start a Focus Session**: Select your desired focus duration
2. **Stay Focused**: The timer counts down while you work
3. **Complete the Session**: Finish the entire session without interruption
4. **Unlock Plants**: Earn new plants based on your focus duration
5. **Build Your Garden**: View and enjoy your growing plant collection

## 🛠️ Development

### Running Tests

```bash
flutter test
```

### Building for Production

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## 📝 License

This project is available for personal and educational use.

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## 📧 Contact

Project Link: [https://github.com/kashifumair125/Focus-Garden](https://github.com/kashifumair125/Focus-Garden)

---

Made with ❤️ and Flutter
