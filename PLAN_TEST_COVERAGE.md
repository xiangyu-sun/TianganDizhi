# Test Coverage Improvement Plan

## Current State

- **Test files:** 3 unit test files, 3 UI test files (mostly boilerplate)
- **Actual tests:** ~5 tests total across 55+ source files
- **Coverage estimate:** <10%
- **Frameworks in use:** Mixed XCTest and Swift Testing

---

## Phase 1: Core Business Logic (Priority: Critical)

### 1.1 Dizhi Hour Mapping Tests
**File to create:** `TianganDizhiTests/DizhiTests.swift`

Test the `Dizhi.init(hourOfDay:)` mapping which is critical business logic:
- Hour 23 and 0 → 子 (zi)
- Hour 1-2 → 丑 (chou)
- Hour 3-4 → 寅 (yin)
- ... all 12 branches
- Edge cases: hour 23, hour 0, boundary hours

**Estimated tests:** 15-20 tests

### 1.2 Date Ganzhi Calculation Tests
**File to create:** `TianganDizhiTests/DateGanzhiTests.swift`

Test `Date.nianGan` and `Date.nianZhi` properties:
- Known historical years (e.g., 2024 = 甲辰)
- Edge cases around Chinese New Year
- Various years across 60-year cycles
- Leap year handling

**Estimated tests:** 15-20 tests

### 1.3 MinuteTimeLineScheduler Tests
**File to create:** `TianganDizhiTests/MinuteTimeLineSchedulerTests.swift`

Test timeline generation:
- Returns correct number of entries (49)
- Entries are 15 minutes apart
- First entry is current time
- Entries span 4 hours total

**Estimated tests:** 5-8 tests

### 1.4 Extend ShichenTimeLineScheduler Tests
**File to update:** `TianganDizhiTests/TianganDizhiTests.swift`

Add tests for:
- `backup()` fallback method
- Edge cases (midnight, noon boundaries)
- Timezone handling

**Estimated tests:** 5-8 additional tests

---

## Phase 2: State Management & Services (Priority: High)

### 2.1 LocationManager Tests
**File to create:** `TianganDizhiTests/LocationManagerTests.swift`

Test async location flows:
- Authorization state handling
- Location caching behavior
- Error cases (`didNotGetResult`, permission denied)
- Timeout scenarios

**Estimated tests:** 10-12 tests

### 2.2 WeatherData Tests
**File to create:** `TianganDizhiTests/WeatherDataTests.swift`

Test weather service:
- Caching logic (avoid redundant API calls)
- Temperature formatting
- Moon phase display text
- Sunrise/sunset calculations
- JSON encoding/decoding for cache

**Estimated tests:** 10-15 tests

### 2.3 SettingsManager Tests
**File to create:** `TianganDizhiTests/SettingsManagerTests.swift`

Test settings persistence:
- Reading from UserDefaults
- Default values when key is missing
- Shared app group access

**Estimated tests:** 5-8 tests

### 2.4 DateProvider Tests
**File to create:** `TianganDizhiTests/DateProviderTests.swift`

Test observable date updates:
- Initial value is current date
- Timer-based updates (with mock timer)
- Published property changes

**Estimated tests:** 3-5 tests

---

## Phase 3: Utility Functions (Priority: Medium)

### 3.1 ChinesePinyin Tests
**File to create:** `TianganDizhiTests/ChinesePinyinTests.swift`

Test string transformation:
- Chinese characters → pinyin
- Mixed Chinese/English strings
- Empty strings
- Special characters

**Estimated tests:** 8-10 tests

### 3.2 MeasurementFormatter Tests
**File to create:** `TianganDizhiTests/MeasurementFormatterTests.swift`

Test temperature formatting:
- `buildTemperatureDescription(high:low:)` output
- Various temperature ranges
- Negative temperatures
- Localization (Celsius display)

**Estimated tests:** 5-8 tests

### 3.3 DateColorModifier Tests
**File to create:** `TianganDizhiTests/DateColorModifierTests.swift`

Test date comparison logic:
- Past dates → secondary color
- Future dates → primary color
- Today edge case

**Estimated tests:** 5-6 tests

---

## Phase 4: UI & Integration Tests (Priority: Lower)

### 4.1 Snapshot Tests for Main Views
**Files to create:** `TianganDizhiUITests/SnapshotTests/`

Using a snapshot testing library (e.g., swift-snapshot-testing):
- MainView in different states
- Widget appearances
- Dark mode vs light mode
- Different device sizes

### 4.2 Localization Tests
**File to create:** `TianganDizhiTests/LocalizationTests.swift`

Verify all localized strings exist:
- Chinese Simplified
- Chinese Traditional
- English
- No missing keys

### 4.3 Widget Timeline Integration Tests
**File to create:** `TianganDizhiTests/WidgetIntegrationTests.swift`

Test widget update flow:
- Timeline generation → entry creation
- Date changes trigger correct updates

---

## Framework Recommendation

**Migrate to Swift Testing for new tests:**
- Already have one file using Swift Testing (`DayDifferenceTest.swift`)
- Better async/await support
- Cleaner `@Test` macro syntax
- Better parameterized testing with `@Test(arguments:)`

**Example structure:**
```swift
import Testing
@testable import TianganDizhi

struct DizhiTests {
    @Test("Hour 0 maps to 子")
    func hourZeroMapsToZi() {
        let dizhi = Dizhi(hourOfDay: 0)
        #expect(dizhi == .zi)
    }

    @Test(arguments: [23, 0])
    func midnightHoursMapsToZi(hour: Int) {
        let dizhi = Dizhi(hourOfDay: hour)
        #expect(dizhi == .zi)
    }
}
```

---

## Implementation Order

| Week | Focus | Files | Est. Tests |
|------|-------|-------|------------|
| 1 | Dizhi + Date Ganzhi | 2 new files | 30-40 |
| 2 | Timeline schedulers | 1 new + 1 update | 10-16 |
| 3 | LocationManager + WeatherData | 2 new files | 20-27 |
| 4 | Settings + DateProvider | 2 new files | 8-13 |
| 5 | Utilities (Pinyin, Formatter) | 3 new files | 18-24 |
| 6 | UI/Snapshot tests | Multiple files | Variable |

**Total estimated new tests:** 86-120 unit tests

---

## Test File Naming Convention

```
TianganDizhiTests/
├── Core/
│   ├── DizhiTests.swift
│   ├── TianganTests.swift
│   ├── ZodiacTests.swift
│   └── DateGanzhiTests.swift
├── Timeline/
│   ├── ShichenTimeLineSchedulerTests.swift
│   ├── MinuteTimeLineSchedulerTests.swift
│   └── WidgetTimelineTests.swift
├── Services/
│   ├── LocationManagerTests.swift
│   ├── WeatherDataTests.swift
│   ├── SettingsManagerTests.swift
│   └── DateProviderTests.swift
├── Utilities/
│   ├── ChinesePinyinTests.swift
│   ├── MeasurementFormatterTests.swift
│   └── DateColorModifierTests.swift
└── Integration/
    └── LocalizationTests.swift
```

---

## Success Metrics

1. **Line coverage target:** 60%+ for core business logic
2. **All Dizhi hour mappings tested:** 24 hours → 12 branches
3. **All Tiangan/Dizhi cycles tested:** At least one full 60-year cycle
4. **Zero regressions:** All existing tests continue to pass
5. **CI integration:** Tests run on every PR via fastlane

---

## Dependencies & Setup

### Required for testing:
- Mock UserDefaults for SettingsManager tests
- Mock CLLocationManager for LocationManager tests
- Mock WeatherKit for WeatherData tests (or use protocol abstraction)

### Optional tools:
- `swift-snapshot-testing` for UI snapshot tests
- Code coverage reports via Xcode or third-party tools

---

## Quick Wins (Start Here)

The following can be implemented immediately with minimal setup:

1. **DizhiTests.swift** - Pure logic, no mocks needed
2. **DateGanzhiTests.swift** - Pure date calculations
3. **MinuteTimeLineSchedulerTests.swift** - Pure logic
4. **ChinesePinyinTests.swift** - Simple string transformations

These 4 files would add ~50 tests with zero infrastructure changes.
