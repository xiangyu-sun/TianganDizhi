
import ChineseAstrologyCalendar
import CoreLocation
import Foundation
import os
@preconcurrency import WeatherKit
import WidgetKit

// MARK: - ChineseMoonPhase + Codable

extension ChineseMoonPhase: @retroactive Codable { }

// MARK: - WeatherData

@MainActor
final class WeatherData: ObservableObject {

  // MARK: Internal

  struct Information: Codable {
    let moonPhase: ChineseMoonPhase
    let moonRise: Date?
    let moonset: Date?

    let sunrise: Date?
    let sunset: Date?
    let noon: Date?
    let midnight: Date?

    let temperatureHigh: Measurement<UnitTemperature>
    let temperatureLow: Measurement<UnitTemperature>

    let condition: String
  }

  /// The forecast plus where and when it was fetched. Persisting the stamp
  /// alongside the payload is what makes the cache usable across processes:
  /// the widget extension and every fresh app launch start with no in-memory
  /// state, so without it the freshness check could never pass and the cache
  /// was write-only.
  struct CachedForecast: Codable {
    let information: Information
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let fetchedAt: Date

    var location: CLLocation { CLLocation(latitude: latitude, longitude: longitude) }
  }

  static let shared = WeatherData()

  /// Replaces the old misspelled `come.uriphium.weatherdata`, which held a bare
  /// `Information` with no fetch stamp. It was only ever a cache, so it is simply
  /// abandoned rather than migrated.
  static let dataCacheKey = "com.uriphium.weatherdata.cached"

  let userDefault: UserDefaults?

  let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.WeatherData", category: "Model")

  @Published private(set) var forcastedWeather: Information?

  init(userDefault: UserDefaults? = Constants.sharedUserDefault) {
    self.userDefault = userDefault
    let cached = Self.readCache(from: userDefault)
    lastUpdatedLocation = cached?.location
    lastUpdatedDate = cached?.fetchedAt
    forcastedWeather = Self.todaysForecast(in: cached)
  }

  /// Today's cached forecast, for processes that must not fetch — the widget
  /// extension can't get location permission, so its timeline provider reads
  /// what the app last stored instead. Returns `nil` once the stored forecast
  /// is from an earlier day, since a daily forecast describes only that day.
  nonisolated static func cachedForecast(
    from userDefault: UserDefaults? = Constants.sharedUserDefault,
    on day: Date = .now) -> Information?
  {
    todaysForecast(in: readCache(from: userDefault), on: day)
  }

  /// A cached forecast is reusable only when the request is both close to
  /// where it was fetched *and* recent — either condition alone isn't
  /// enough. A stationary user 6 hours later, or a user who just flew 1000km
  /// within the last minute, must both trigger a refetch.
  static func shouldUseCachedForecast(lastLocation: CLLocation?, lastDate: Date?, requestedLocation: CLLocation, now: Date = .now) -> Bool {
    guard let lastLocation, let lastDate else { return false }
    let distance = lastLocation.distance(from: requestedLocation)
    return distance < 1000 && lastDate.distance(to: now) < 60 * 60
  }

  @discardableResult
  func dailyForecast(for location: CLLocation) async throws -> Information? {
    if WeatherData.shouldUseCachedForecast(lastLocation: lastUpdatedLocation, lastDate: lastUpdatedDate, requestedLocation: location) {
      logger.log(level: .debug, "fetching forcast aborted due to not matching requirement")
      if let cached = Self.todaysForecast(in: Self.readCache(from: userDefault)) {
        forcastedWeather = cached
        return cached
      }
    }

    let dayWeather: Forecast<DayWeather> = try await WeatherService.shared.weather(
      for: location,
      including: .daily)

    logger.debug("fetched \(dayWeather.forecast.count) day(s) of forecast")

    if let today = dayWeather.forecast.first, let day = Date.now.chineseDay() {
      let data = Information(
        moonPhase: today.moon.phase.moonPhase(day: day),
        moonRise: today.moon.moonrise,
        moonset: today.moon.moonset,
        sunrise: today.sun.sunrise,
        sunset: today.sun.sunset,
        noon: today.sun.solarNoon,
        midnight: today.sun.solarMidnight,
        temperatureHigh: today.highTemperature,
        temperatureLow: today.lowTemperature,
        condition: today.condition.description)

      forcastedWeather = data

      let now = Date.now
      let cached = CachedForecast(
        information: data,
        latitude: location.coordinate.latitude,
        longitude: location.coordinate.longitude,
        fetchedAt: now)
      if let encoded = try? JSONEncoder().encode(cached) {
        userDefault?.set(encoded, forKey: Self.dataCacheKey)
      }
      lastUpdatedLocation = location
      lastUpdatedDate = now

      return data
    } else {
      return nil
    }
  }

  // MARK: Private

  private nonisolated static func readCache(from userDefault: UserDefaults?) -> CachedForecast? {
    guard let data = userDefault?.data(forKey: dataCacheKey) else { return nil }
    return try? JSONDecoder().decode(CachedForecast.self, from: data)
  }

  private nonisolated static func todaysForecast(in cached: CachedForecast?, on day: Date = .now) -> Information? {
    guard let cached, Calendar.current.isDate(cached.fetchedAt, inSameDayAs: day) else { return nil }
    return cached.information
  }

  private var lastUpdatedLocation: CLLocation?
  private var lastUpdatedDate: Date?

}
