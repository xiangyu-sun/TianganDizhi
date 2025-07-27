# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TianganDizhi (天干地支) is a comprehensive Chinese astrology and calendar iOS/macOS/watchOS application that displays traditional Chinese calendar information, moon phases, weather data, and provides various widgets. The app supports multiple platforms and includes extensive localization.

## Build Commands

### Testing
```bash
# Run tests on iPhone 8 Plus and iPad Pro using fastlane
fastlane ios tests

# Run tests directly with xcodebuild
xcodebuild test -scheme TianganDizhi -destination 'platform=iOS Simulator,name=iPhone 8 Plus'
```

### Building
```bash
# Build for release using fastlane
fastlane ios release

# Build specific schemes
xcodebuild -scheme TianganDizhi build
xcodebuild -scheme ShiChenExtension build
xcodebuild -scheme "ShichenWatch Watch App" build
```

### Screenshots
```bash
# Capture app store screenshots
fastlane ios screenshots
```

## Architecture Overview

### Multi-Target Structure
The project consists of multiple targets for different platforms and widget extensions:

- **TianganDizhi** - Main iOS/macOS app
- **ShiChenExtension** - iOS widget extension
- **ShichenWatch Watch App** - watchOS app  
- **ShichenWatch** - watchOS widget extension
- **ShichenMacWidget** - macOS widget extension

### Core Dependencies
The app relies heavily on custom Swift packages for Chinese astrology calculations:
- `ChineseAstrologyCalendar` - Core calendar and date calculations
- `ChineseTranditionalMusicCore` - Traditional music theory
- `JingluoShuxueCore` - Traditional Chinese medicine concepts
- `Bagua` - I Ching hexagram calculations
- `Astral` - Astronomical calculations
- `ShangdianKit` - Commerce/subscription features

### Key Architecture Patterns

#### Date Management
- `DateProvider` - Observable object for current date updates
- Custom date extensions (`Date+Ganzhi.swift`, `Date+Jieqi.swift`) for Chinese calendar calculations
- `DayConverter` - Handles timezone conversions (GTM8 support)

#### Settings Management  
- `SettingsManager` - Centralized app settings using `@AppStorage`
- Shared UserDefaults between app and extensions via app groups
- Constants defined in `Constants.swift` for consistent setting keys

#### Widget Timeline Architecture
- `ShichenTimeLineSceduler` - Manages widget update timelines
- `MinuteTimeLineScheduler` - Handles minute-based updates
- Separate timeline providers for different widget types

#### UI Structure
The main app uses SwiftUI with a tab-based navigation:
- **MainView** - Primary时辰 (Shichen) display with circular clock
- **KnowledgeView** - Educational content about Chinese astrology
- **GuaListView** - I Ching hexagram information  
- **ChartListView** - Comprehensive charts and visualizations
- **SettingsView** - App configuration

### Platform-Specific Considerations

#### iOS/iPadOS
- Supports multiple size classes (compact/regular)
- Includes iOS widgets with various sizes
- Weather integration using WeatherKit

#### macOS
- Menu bar extra functionality showing current information
- Platform-specific UI adjustments using `#if os(macOS)`

#### watchOS  
- Dedicated watch app with simplified UI
- Watch-specific widget support
- Optimized for small screens

### Shared Code Organization
- `AppWidgetShared/` - Code shared between main app and widgets
- `Utilities/` - Common utility functions and extensions
- Asset catalogs organized by platform and feature

### Localization
- Supports Chinese (Simplified/Traditional) and English
- Uses `.xcstrings` files for modern localization
- Fastlane integration for App Store metadata in multiple languages

### Testing Structure
- Unit tests in `TianganDizhiTests/`
- UI tests in `TianganDizhiUITests/` 
- Timeline testing for widget functionality

## Development Notes

### Font Management
The app uses a custom font "WeibeiTC-Bold" with fallback to system fonts controlled by user preference.

### Weather Integration
Weather data is fetched using Apple's WeatherKit (iOS 16+) and integrated with location services for accurate sunrise/sunset times.

### Widget Development
When working on widgets, note that they share significant code with the main app through the `AppWidgetShared` folder. Timeline updates are coordinated between the app and widgets.

### Traditional Chinese Features
The app includes extensive traditional Chinese astrology features including:
- Tiangan (天干) and Dizhi (地支) stems and branches
- Jieqi (節氣) solar terms
- Moon phase calculations with Chinese names
- Twelve hour periods (Shichen 時辰)
- I Ching hexagrams and traditional symbolism