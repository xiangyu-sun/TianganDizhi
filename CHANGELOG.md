# Changelog

## [Unreleased]

### Performance
- **Single DateProvider instance** — `DateProvider` is now created once as `@StateObject` in `TianganDizhiApp` and injected via `@EnvironmentObject`. Previously two independent instances existed (one in the app, one in `MainView`), causing two parallel 1-second timers and redundant re-renders.
- **Smart timer filtering** — `DateProvider` timer fires every second but only publishes when the minute changes (shichen/ke granularity), eliminating unnecessary view updates every second.
- **Cached heavy date computations** — `DayConverter.find(day:month:inNextYears:)` and Spring Festival title string are now cached in `@State` properties in `MainView` and only rebuilt on appear or when `useGTM8` changes, not on every timer tick.
- **Eliminated duplicate `LunarMansion` computation** — `LunarMansion.lunarMansion(date:)` was called twice per render; now computed once as a local `let` binding.
- **Removed no-op `withAnimation` wrappers** — `withAnimation { ViewBuilder }` was wrapping view builder closures (not state mutations), which had no effect and was removed.
- **Consolidated duplicate `scenePhase` handlers** — two identical `.onChange(of: scenePhase)` observers existed inside if/else branches; collapsed into one.

### Bug Fixes
- **`WeatherData.shared` lifecycle** — Changed from `@StateObject` (ownership) to `@ObservedObject` (observation of existing singleton) in `MainView`, `MenuBarContentView`, `ExtraLargeWidgetView`, and `MediumWidgetView`. Using `@StateObject` with a singleton causes it to be re-initialized on first render rather than observing the shared instance.
- **`WatchStackView` container background** — Was calling `.containerBackground(for: .widget)` directly, bypassing the `#available` safety wrapper. Now uses the shared `containerBackgroundForWidget` modifier.
- **macOS Settings button** — "Open Settings" in the menu bar extra previously posted `NSNotification.Name("ShowSettings")` with no observer. Now calls `NSApp.sendAction(Selector("showSettingsWindow:"), ...)` which correctly opens the SwiftUI Settings scene.
- **`NSApplication.activate(ignoringOtherApps:)` deprecation** — Replaced with `NSApplication.activate()` (macOS 14+ API) in `MenuBarContentView`.
- **Weather attribution link** — Replaced `Text(...).onTapGesture { UIApplication.shared.open(...) }` with `Link(...)` for correct semantic behaviour and accessibility.

### Accessibility
- **`CircularContainerView`** — Added `.accessibilityElement(children: .ignore)`, `.accessibilityLabel` with current shichen and hour, `.accessibilityAddTraits(.updatesFrequently)`. Decorative stroke circle marked `.accessibilityHidden(true)`.
- **`MainView` shichen block** — Inner `VStack` (ke count + alias + organ) grouped with `.accessibilityElement(children: .combine)`, labelled with shichen name, ke, and organ reference. Marked `.updatesFrequently`.
- **`MainView` stellar mansion row** — `HStack` grouped with `.accessibilityElement(children: .combine)` and explicit label using full Chinese punctuation.
- **`JieqiCell`** — Decorative solar-term image marked `.accessibilityHidden(true)`; cell grouped with `.accessibilityElement(children: .combine)` and a composed label of name, type (節/氣), and description.
- **`TwelveGodsListView`** — Background images marked `.accessibilityHidden(true)`; `TwelveGodCell` grouped and labelled with god name, meaning, auspicious, and inauspicious text.
- **`WuxingView`** — Each element row grouped with `.accessibilityElement(children: .combine)` so VoiceOver reads the full row as one unit.
- **`MoonInformationView`** — Moon phase SF Symbol marked `.accessibilityHidden(true)`; whole view grouped with `.accessibilityElement(children: .combine)`.

### Contrast / Color
- **Wuxing Metal (金)** — Pure white `(1, 1, 1)` → silver-gray `(0.75, 0.75, 0.80)` for visible contrast on light backgrounds.
- **Wuxing Water (水)** — Pure black `(0, 0, 0)` → dark navy `(0.10, 0.12, 0.35)` for visible contrast on dark backgrounds.
- **Wuxing Earth (土)** — Bright yellow `#FFCC00` (~1.5:1 contrast) → deep amber-gold `(0.80, 0.55, 0.0)` for improved legibility.

### Code Quality
- **State management** — `@State var date: Date` changed to `let date: Date` in `RetangularWidgetView`, `CircularWidgetView`, `InlineWidgetView`, `CornerView`; `@State var wetherData` and `@State var info` changed to `let` in `WatchMainView`, `SunInformationView`, `MoonInformationView` — these are injected values, never mutated by the view.
- **`BaguaView.viewData`** — Changed from `@State var viewData` to `let viewData` (injected, not mutated).
- **`rotationOn` visibility** — `@State var rotationOn` made `@State private var rotationOn` in `BaguaView`, `ShierPiguaView`, and `YangliShierPiguaView`.
- **`.foregroundColor()` → `.foregroundStyle()`** — Migrated all 59 usages across 23 files to the non-deprecated API.
- **`PreviewProvider` → `#Preview` macro** — Migrated all 47 files from the legacy `PreviewProvider` protocol to the `#Preview` macro introduced in Xcode 15 / Swift 5.9.
