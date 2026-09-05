
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

  static let shared = WeatherData()

  let dataCacheKey = "come.uriphium.weatherdata"

  let userDefault: UserDefaults?

  let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.WeatherData", category: "Model")

  @Published private(set) var forcastedWeather: Information?

  init(userDefault: UserDefaults? = Constants.sharedUserDefault) {
    self.userDefault = userDefault
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

  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
  @discardableResult
  func dailyForecast(for location: CLLocation) async throws -> Information? {
    if WeatherData.shouldUseCachedForecast(lastLocation: lastUpdatedLocation, lastDate: lastUpdatedDate, requestedLocation: location) {
      logger.log(level: .debug, "fetching forcast aborted due to not matching requirement")
      guard let data = userDefault?.data(forKey: dataCacheKey) else {
        return nil
      }
      let decoder = JSONDecoder()
      let cached = try decoder.decode(Information.self, from: data)
      forcastedWeather = cached
      return cached
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

      Task {
        let encoder = JSONEncoder()

        if let encoded = try? encoder.encode(data) {
          userDefault?.setValue(encoded, forKey: dataCacheKey)
          self.update(location: location)
        }
      }

      return data
    } else {
      return nil
    }
  }

  @MainActor
  func update(location: CLLocation) {
    lastUpdatedLocation = location
    lastUpdatedDate = Date.now
  }

  // MARK: Private

  private var lastUpdatedLocation: CLLocation?
  private var lastUpdatedDate: Date?

}
