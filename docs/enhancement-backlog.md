# Enhancement backlog (platform features)

Investigation from 2026-11-03, checking the app against Apple's App Intents (SDK 26/27) and
SwiftUI 27 guidance. **Deferred: none of these are planned for the current version.**

## State of the code at the time
- 9 iOS widgets, the macOS widget and the watch widgets use `IntentConfiguration` backed by the
  legacy SiriKit `ShiChen/Base.lproj/ShiChen.intentdefinition`. Only `CalendarWidget`,
  `JieqiHealthWidget`, `LuckWidget` and the watch stack (`ShichenWatch/Stack/ConfigurationAppIntent.swift`)
  use `AppIntentTimelineProvider`.
- No `AppShortcutsProvider`, `AppEntity`, Spotlight indexing, `ControlWidget`, `NSUserActivity`
  or interactive snippets.
- `ShichenActivityAttributes` and `ShiChen/Shared/LiveActivity/ShichenLockScreenView.swift` exist,
  but nothing calls `Activity.request`, so the Live Activity never runs.
- `SWIFT_VERSION = 5.0` on all targets. 24 `accessibilityLabel`s, no Dynamic Type handling.

## Candidates, ranked

### High value (App Intents)
1. **App Shortcuts** (Siri, Spotlight, Action button): "現在是什麼時辰", "下一個節氣",
   "今天農曆幾號", "距離{節日}還有幾天".
2. **`AppEntity` for special days**, backed by `SpecialDayCatalog.sources()` (festivals, 節氣,
   自訂節日). One entity serves shortcuts, the countdown widget parameter and Spotlight
   (`IndexedEntity`; `IndexedEntityQuery` reindex on iOS 27). The `id` scheme and any `AppEnum`
   raw values are a public contract and must stay stable.
3. **Migrate the legacy widgets to `AppIntentConfiguration`.** Unblocks 1–2. Riskiest item:
   users' saved widget configurations must carry over.
4. **Interactive snippets** (`SnippetIntent`, iOS 26): a 時辰/節氣 card as the Siri/Shortcuts answer.
5. **Control widgets** (iOS 18+): Control Center / lock screen controls to open 時辰 or 節日曆.

### Medium
6. **Finish or remove the Live Activity**, e.g. countdown to the next 節氣/festival, or the
   current 時辰 as it changes.
7. **Onscreen entity**: annotate the festival detail screen's `NSUserActivity` with
   `appEntityIdentifier` so Siri / Apple Intelligence resolve "this festival".
8. **Intent tests** with `AppIntentsTesting` (iOS 27) in the existing test plan.

### SwiftUI 27 polish
9. `CustomHolidaysView`: drag to reorder with `.reorderable()` + `.reorderContainer(for:)`
   (only `.onDelete` today).
10. Toolbars: `visibilityPriority` / `toolbarMinimizeBehavior` for crowded bars on the foldable
    iPhone and short windows.
11. SDK 27 build risks: `@State` is now a macro; unified `@ContentBuilder` can be ambiguous in
    `overlay`/`background` and slower to type-check in Swift Charts (the `Chart/` tab).

## Suggested order
Start with 1 + 2 together (most value, existing widgets untouched), then 3 once the entity exists.

## Related reviews not yet run
- App Intents best-practice review before items 1–3.
- Accessibility review (Dynamic Type, VoiceOver on the glyph dials).
- Xcode security build settings audit; Swift 6 / strict concurrency migration.
- Instruments profiling of the per-minute timeline and widget timeline cost.
- App Store ASO and the fall 2026 header/search creative assets.
