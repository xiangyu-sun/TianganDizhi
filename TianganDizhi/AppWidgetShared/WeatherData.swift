
import CoreLocation
import Foundation
import os
import WeatherKit
import ChineseAstrologyCalendar
import WidgetKit

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
    
    let temperatureHigh: Measurement<UnitTemperature>
    let temperatureLow: Measurement<UnitTemperature>
    
    let condition: String
  }

  static let shared = WeatherData()

  let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.WeatherData", category: "Model")

  @Published private(set) var forcastedWeather: Information?
  
  private var lastUpdatedLocation: CLLocation?
  private var lastUpdatedDate: Date?

  @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
  @discardableResult
  func dailyForecast(for location: CLLocation) async throws -> Information? {
    if let distance = lastUpdatedLocation?.distance(from: location), distance <= 1000,
       let lastUpdatedDate, lastUpdatedDate.distance(to: Date()) < 2 * 60 * 60
    {
      return nil
    }
    
    lastUpdatedLocation = location
    lastUpdatedDate = Date()
    
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
        midnight: today.sun.solarMidnight,
        temperatureHigh: today.highTemperature,
        temperatureLow: today.lowTemperature,
        condition: today.condition.description
        
      )
      
      forcastedWeather = data
      
      WidgetCenter.shared.reloadAllTimelines()
      
      return data
    } else {
      return nil
    }
  }
}
