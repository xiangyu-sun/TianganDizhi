
import Foundation
import WeatherKit
import CoreLocation
import os

@MainActor
final class WeatherData: ObservableObject {
    
    struct Information {
        let moonPhaseDisplayName: String
    }
    
    let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.WeatherData", category: "Model")
    
    @Published private(set) var forcastedWeather: Information?
    
    static let shared = WeatherData()
    
    @available(iOS 16.0, watchOS 9.0, *)
    @discardableResult
    func dailyForecast(for location: CLLocation) async throws -> Information? {
        
        let dayWeather: Forecast<DayWeather>? = await Task.detached(priority: .userInitiated) {
            let forcast = try? await WeatherService.shared.weather(
                for: location,
                including: .daily)
            return forcast
        }.value
      
      logger.debug("\(dayWeather.debugDescription)")
      
      if let dayWeather {
        let data = Information(moonPhaseDisplayName: dayWeather.forecast.first?.moon.phase.description ?? "")
        forcastedWeather = data
        return data
      } else {
        return nil
      }
    
   
    }
}
