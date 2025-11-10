# 🌱 Focus Garden

A beautiful gamified focus timer app that helps you stay productive while growing your virtual garden. Complete focus sessions to unlock and collect various plants!

## ✨ Features

### Core Features
- **⏱️ Focus Timer**: Customizable Pomodoro-style timer to help you concentrate on tasks
- **🌿 Plant Rewards**: Unlock 13 beautiful plants by completing focus sessions of varying durations
- **🏡 Virtual Garden**: Display and admire your collected plants with animated effects
- **📊 Statistics**: Track your focus sessions, streaks, and productivity over time
- **🎨 Beautiful UI**: Clean, nature-inspired design with smooth animations
- **💾 Local Storage**: All your data is stored locally on your device using Hive
- **🔊 Audio Feedback**: Real sound effects for timer completion and plant unlocks

### Gamification
- **⭐ XP & Levels**: Earn experience points for every focus session and level up your gardener
- **🏅 Daily Challenges**: Complete unique daily challenges for bonus XP rewards
- **🔥 Streak Tracking**: Build and maintain your focus streak across consecutive days
- **🎯 Achievements**: Unlock special achievements for reaching milestones

### Customization
- **🎨 9 Garden Themes**: Unlock beautiful themes as you level up (Classic, Forest, Sakura, Ocean, Sunset, Lavender, Autumn, Midnight, Zen)
- **🔔 Smart Notifications**: Optional daily reminders to keep you on track
- **⚙️ Flexible Settings**: Customize timer defaults, sounds, and notifications
- **💬 Motivational Quotes**: Get inspired with contextual motivational quotes

### Enhanced Experience
- **📈 Progress Tracking**: Visualize your journey with XP bars and progress indicators
- **🌟 Rarity System**: Plants come in 5 rarity tiers from Common to Legendary
- **🎉 Celebrations**: Special animations and notifications for level-ups and achievements
- **📱 Cross-Platform**: Works on Android, iOS, Web, Windows, macOS, and Linux

## 🌸 Plant Collection

Grow your garden by completing focus sessions of different durations:

### Common (5-15 minutes)
- 🌼 **White Daisy** - Your first cheerful flower
- 🌱 **Green Sprout** - The beginning of something beautiful
- 🌷 **Pink Tulip** - A delicate bloom of early spring

### Uncommon (20-30 minutes)
- 🌻 **Sunflower** - Bright and always facing the sun
- 🌿 **Forest Fern** - Elegant plant from deep forest
- 🌵 **Desert Cactus** - Resilient and strong

### Rare (45-60 minutes)
- 🌹 **Red Rose** - Earned through dedication
- 🌸 **Cherry Blossom** - Representing fleeting beauty
- 🌳 **Oak Sapling** - Strong and steady

### Epic (75-90 minutes)
- 🌺 **Purple Orchid** - Rare and exotic beauty
- 🪷 **Lotus Flower** - Symbol of purity and enlightenment

### Legendary (120+ minutes)
- 🪴 **Ancient Bonsai** - Masterpiece of patience
- 🌲 **World Tree** - Ultimate achievement for masters

*The longer you focus, the more rare plants you can unlock!*

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
- **[Riverpod](https://riverpod.dev/)** - Powerful state management solution
- **[Hive](https://docs.hivedb.dev/)** - Fast, lightweight local database
- **[Lottie](https://pub.dev/packages/lottie)** - Beautiful JSON animations
- **[AudioPlayers](https://pub.dev/packages/audioplayers)** - Audio playback for sound effects
- **[Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)** - Local push notifications
- **[FL Chart](https://pub.dev/packages/fl_chart)** - Beautiful charts for statistics

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
