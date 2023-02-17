
import CoreLocation
import Foundation
import os
import WeatherKit
import ChineseAstrologyCalendar

@MainActor
final class WeatherData: ObservableObject {

  struct Information {
    let moonPhase: ChineseMoonPhase
    let moonRise: Date?
    let moonset: Date?
    
    let sunrise: Date?
    let sunset: Date?
    let noon: Date?
    let midnight: Date?
  }

  static let shared = WeatherData()

  let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.WeatherData", category: "Model")

  @Published private(set) var forcastedWeather: Information?

  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
  @discardableResult
  func dailyForecast(for location: CLLocation) async throws -> Information? {
    let dayWeather: Forecast<DayWeather>? = await Task.detached(priority: .userInitiated) {
      let forcast = try? await WeatherService.shared.weather(
        for: location,
        including: .daily)
      return forcast
    }.value

    logger.debug("\(dayWeather.debugDescription)")
    
   
    
    if let dayWeather, let today = dayWeather.forecast.first, let day  = Date().chineseDay() {
      let data = Information(
        moonPhase: today.moon.phase.moonPhase(day: day),
        moonRise: today.moon.moonrise,
        moonset: today.moon.moonset,
        sunrise: today.sun.sunrise,
        sunset: today.sun.sunset,
        noon: today.sun.solarNoon,
        midnight: today.sun.solarMidnight
      )
      
      forcastedWeather = data
      return data
    } else {
      return nil
    }
  }
}
