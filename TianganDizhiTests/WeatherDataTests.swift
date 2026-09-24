import CoreLocation
import Foundation
import Testing
@testable import TianganDizhi

/// Regression tests for WeatherData's cache, exercised entirely through the
/// cache-hit path so no real WeatherKit network call is ever made: the
/// throttle used `||` where it meant `&&` (so a stationary user's forecast
/// froze forever), and the cache stamp lived only in memory, so no new
/// process — app launch or widget — could ever read the stored forecast.
@MainActor
@Suite struct WeatherDataTests {

  private static func makeSuite() -> UserDefaults {
    let suite = try! #require(UserDefaults(suiteName: "WeatherDataTests.\(UUID().uuidString)"))
    return suite
  }

  private static func makeSampleInformation() -> WeatherData.Information {
    WeatherData.Information(
      moonPhase: .fullMoon,
      moonRise: Date(timeIntervalSince1970: 100),
      moonset: Date(timeIntervalSince1970: 200),
      sunrise: Date(timeIntervalSince1970: 300),
      sunset: Date(timeIntervalSince1970: 400),
      noon: Date(timeIntervalSince1970: 500),
      midnight: Date(timeIntervalSince1970: 600),
      temperatureHigh: Measurement(value: 20, unit: .celsius),
      temperatureLow: Measurement(value: 10, unit: .celsius),
      condition: "clear")
  }

  private static func store(
    _ information: WeatherData.Information,
    at location: CLLocation,
    fetchedAt: Date,
    in suite: UserDefaults) throws
  {
    let cached = WeatherData.CachedForecast(
      information: information,
      latitude: location.coordinate.latitude,
      longitude: location.coordinate.longitude,
      fetchedAt: fetchedAt)
    suite.set(try JSONEncoder().encode(cached), forKey: WeatherData.dataCacheKey)
  }

  /// The cache used to keep its location/date stamp in memory only, so a new
  /// process — every app launch, and every widget render — could never pass
  /// the freshness check and the stored forecast was never read.
  @Test func freshProcessReusesCacheWrittenByAnEarlierOne() async throws {
    let suite = Self.makeSuite()
    let location = CLLocation(latitude: 37.3318, longitude: -122.0312)
    let sample = Self.makeSampleInformation()
    try Self.store(sample, at: location, fetchedAt: .now.addingTimeInterval(-5 * 60), in: suite)

    // A brand-new instance stands in for a new process.
    let weatherData = WeatherData(userDefault: suite)
    #expect(weatherData.forcastedWeather?.condition == sample.condition, "today's cache is published on init")

    let result = try await weatherData.dailyForecast(for: location)
    #expect(result?.condition == sample.condition)
    #expect(weatherData.forcastedWeather?.condition == sample.condition)
  }

  /// The widget extension reads the cache instead of fetching; a forecast from
  /// an earlier day describes the wrong day and must not be shown.
  @Test func widgetCacheReadIsLimitedToTheDayItWasFetched() throws {
    let suite = Self.makeSuite()
    let location = CLLocation(latitude: 37.3318, longitude: -122.0312)
    let fetchedAt = Date()
    try Self.store(Self.makeSampleInformation(), at: location, fetchedAt: fetchedAt, in: suite)

    #expect(WeatherData.cachedForecast(from: suite, on: fetchedAt)?.condition == "clear")
    let tomorrow = try #require(Calendar.current.date(byAdding: .day, value: 1, to: fetchedAt))
    #expect(WeatherData.cachedForecast(from: suite, on: tomorrow) == nil)
    #expect(WeatherData.cachedForecast(from: Self.makeSuite()) == nil, "empty cache")
  }

  @Test func throttleRequiresBothCloseAndRecent() {
    let here = CLLocation(latitude: 37.3318, longitude: -122.0312)
    let farAway = CLLocation(latitude: 37.35, longitude: -122.0312) // ~2km north
    #expect(here.distance(from: farAway) > 1000)

    let now = Date()
    let fiveMinutesAgo = now.addingTimeInterval(-5 * 60)
    let twoHoursAgo = now.addingTimeInterval(-2 * 60 * 60)

    // Close and recent: reuse the cache.
    #expect(WeatherData.shouldUseCachedForecast(lastLocation: here, lastDate: fiveMinutesAgo, requestedLocation: here, now: now))

    // Recent but far away — moved 2km within the last 5 minutes. The
    // pre-fix `||` would reuse the cache here; `&&` must not.
    #expect(!WeatherData.shouldUseCachedForecast(lastLocation: here, lastDate: fiveMinutesAgo, requestedLocation: farAway, now: now))

    // Close but stale — stationary for 2 hours. The pre-fix `||` would
    // reuse the cache here too; `&&` must not.
    #expect(!WeatherData.shouldUseCachedForecast(lastLocation: here, lastDate: twoHoursAgo, requestedLocation: here, now: now))

    // Neither close nor recent.
    #expect(!WeatherData.shouldUseCachedForecast(lastLocation: here, lastDate: twoHoursAgo, requestedLocation: farAway, now: now))
  }
}
