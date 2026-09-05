import CoreLocation
import Foundation
import Testing
@testable import TianganDizhi

/// Regression tests for two WeatherData bugs, exercised entirely through the
/// cache-hit path so no real WeatherKit network call is ever made: the
/// throttle used `||` where it meant `&&` (so a stationary user's forecast
/// froze forever), and the cache-hit branch decoded a value without
/// publishing it to `forcastedWeather`, leaving widgets with no weather on a
/// cold launch despite valid cached data sitting in the app group.
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

  @Test func cacheHitPublishesForcastedWeather() async throws {
    let suite = Self.makeSuite()
    let weatherData = WeatherData(userDefault: suite)
    let location = CLLocation(latitude: 37.3318, longitude: -122.0312)
    let sample = Self.makeSampleInformation()

    let encoded = try JSONEncoder().encode(sample)
    suite.set(encoded, forKey: weatherData.dataCacheKey)
    weatherData.update(location: location)

    #expect(weatherData.forcastedWeather == nil, "sanity check: nothing published yet")

    let result = try await weatherData.dailyForecast(for: location)

    #expect(result?.condition == sample.condition)
    #expect(weatherData.forcastedWeather?.condition == sample.condition, "cache hit must publish forcastedWeather, not just return it")
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
