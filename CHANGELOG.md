# Changelog

All notable changes to Focus Garden will be documented in this file.

## [2.0.0] - 2025-11-10

### 🎉 Major Update: Gamification & Enhanced Features

This release transforms Focus Garden from a simple timer app into a comprehensive gamified productivity system!

### ✨ New Features

#### Gamification System
- **XP & Leveling System**: Earn experience points for every completed focus session
  - Dynamic XP rewards based on session duration (longer sessions = more XP)
  - 8 progressive titles from "Seedling" to "Legendary Gardener"
  - Level-based progression with exponential growth curve
  - Visual XP bar and level display on timer screen

- **Daily Challenges**: New rotating challenges every day
  - 5 different challenge types (Sprint Focus, Deep Work, Marathon Mind, etc.)
  - Bonus XP rewards for completing challenges
  - Real-time progress tracking
  - Visual challenge card on timer screen

- **Achievements System**: Unlock achievements for reaching milestones
  - First Focus, One Hour Focused, Dedicated Focuser, Streak Master
  - Visual display in statistics screen
  - Special celebration animations

#### Enhanced Plant Collection
- **Expanded Plant Library**: 13 unique plants (up from 8)
  - New plants: Pink Tulip, Desert Cactus, Cherry Blossom, Lotus Flower, World Tree
  - Better progression from 5 minutes to 180 minutes
  - More balanced rarity distribution

- **Emoji Fallbacks**: All plants now have emoji representations
  - Graceful fallback when images aren't available
  - Maintains visual appeal across all platforms
  - Unicode emoji support for universal compatibility

#### Customizable Themes
- **9 Beautiful Garden Themes**: Unlock new themes as you level up
  - Classic Garden (Level 0)
  - Forest Retreat (Level 5)
  - Sakura Blossoms (Level 10)
  - Ocean Breeze (Level 15)
  - Sunset Garden (Level 20)
  - Lavender Fields (Level 25)
  - Autumn Harvest (Level 30)
  - Midnight Garden (Level 40)
  - Zen Garden (Level 50)
- Each theme has unique color palettes and mood
- Themes change entire app appearance
- Level-gated to provide long-term goals

#### Motivational Quotes
- **30+ Inspirational Quotes**: Context-aware motivational messages
  - Time-based quotes (morning, afternoon, evening)
  - Streak-based encouragement
  - Milestone celebrations
  - First-time user welcome messages
- Quotes from famous productivity experts and thinkers
- Beautiful card display on timer screen

#### Settings & Customization
- **Comprehensive Settings Screen**: New dedicated settings interface
  - Theme selection with unlock status
  - Sound effects toggle
  - Haptic feedback control
  - Notification preferences
  - Default timer duration
  - Data export and reset options

#### Audio System
- **Real Audio Playback**: Actual sound effects (replacing haptic-only)
  - Timer completion sound
  - Plant unlock celebration sound
  - Configurable volume and enable/disable
  - Audio player integration with audioplayers package

#### Notifications
- **Smart Notifications**: Optional reminder system
  - Daily focus reminders at custom times
  - Streak maintenance reminders
  - Milestone achievement notifications
  - Configurable through settings

### 🔧 Improvements

#### UI/UX Enhancements
- Added 4th navigation tab for Settings
- Redesigned timer screen with more information cards
- Level and XP display prominently shown
- Daily challenge progress card
- Motivational quote card (when timer is idle)
- Better visual hierarchy and information density
- Improved card designs with better spacing

#### Technical Improvements
- Reactive theme switching using Riverpod
- Better state management architecture
- More modular service layer
- Cleaner separation of concerns
- Fixed PlantDatabase initialization (no more DateTime.now() for locked plants)
- Better error handling in PlantWidget with emoji fallbacks

### 🐛 Bug Fixes
- Fixed plant unlock logic where all plants had current date
- Fixed audio service (was only using haptics, now plays actual sounds)
- Improved state management for reactive UI updates
- Fixed theme not persisting across app restarts
- Better error handling for missing assets

### 📦 Dependencies Added
- `audioplayers: ^6.1.0` - Audio playback
- `flutter_local_notifications: ^18.0.1` - Local notifications
- `fl_chart: ^0.69.2` - Charts for statistics (future use)
- `intl: ^0.19.0` - Internationalization and date formatting

### 📚 Documentation
- Updated README with comprehensive feature list
- Added detailed plant collection breakdown
- Documented all new gamification features
- Added changelog (this file!)

### 🎯 What's Next (Future Improvements)
- Calendar view for tracking focus history
- Charts and graphs in statistics screen
- Social features (compare with friends)
- More plant varieties
- Seasonal events and limited-time challenges
- Background timer support
- Apple Watch / Wear OS companion apps
- Cloud backup and sync

---

## [1.0.0] - 2025-11-09

### Initial Release
- Basic focus timer functionality
- Plant reward system
- Garden collection view
- Statistics tracking
- Local data storage with Hive
- Basic animations
- 8 plants across 4 rarity tiers
