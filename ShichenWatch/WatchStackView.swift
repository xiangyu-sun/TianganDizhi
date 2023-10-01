import SwiftUI
import WidgetKit
import ChineseAstrologyCalendar

// MARK: - MediumWidgetView
@available(watchOSApplicationExtension 10.0, *)
struct WatchStackView: View {
  let date: Date
  @Environment(\.widgetFamily) var widgetFamily
  
  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false

  @Environment(\.footnote) var footnote
  
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false

  #if os(iOS) || os(macOS)
  @StateObject var weatherData = WeatherData.shared
  #endif

  var body: some View {
    let shichen = date.shichen!

    VStack {
      FullDateTitleView(date: date)
        .font(footnote)
      
      #if os(iOS) || os(macOS)
      if let value = weatherData.forcastedWeather {
        Text(
          MeasurmentFormatterManager
            .buildTemperatureDescription(high: value.temperatureHigh, low: value.temperatureLow) + "，\(value.condition)")
          .font(footnote)
          .foregroundColor(Color.secondary)
      }
      #endif

      HStack {
        
        VStack {
          Text("\(shichen.dizhi.previous.displayHourText)")
            .font(footnote)
          ShichenWatchInformationView(shichen: shichen.dizhi.previous)
        }
        .foregroundColor(Color.secondary)

        VStack {
          Text("\(shichen.dizhi.displayHourText)")
            .font(footnote)
            .scaleEffect(1.1)
          
          ShichenWatchInformationView(shichen: shichen.dizhi)
        }

   
        VStack {
          Text("\(shichen.dizhi.next.displayHourText)")
            .font(footnote)
     
          ShichenWatchInformationView(shichen: shichen.dizhi.next)
        }
        .foregroundColor(Color.secondary)
      }
      Spacer()
    }
    .widgetAccentable()
    #if os(iOS) || os(macOS)
    .onAppear {
      if #available(iOS 16.0, macOS 13.0, *) {
        Task {
          do {
            if let location = LocationManager.shared.lastLocation {
              try await self.weatherData.dailyForecast(for: location)
            } else {
              let location = try await LocationManager.shared.startLocationUpdate()
              try await self.weatherData.dailyForecast(for: location)
            }
          } catch {
            print(error)
          }
        }
      }
    }
    #endif
    .foregroundColor(springFestiveForegroundEnabled ? Color("springfestivaltext") : Color.primary)
    .containerBackground(for: .widget) {
      Color.black
    }
  }
}

struct ShichenWatchInformationView: View {
  
  let shichen: Dizhi
  @Environment(\.footnote) var footnote
  
  var body: some View {
    
    HStack {
      Text(shichen.aliasName)
      Text(shichen.organReference)
    }
    .widgetAccentable()
    .font(footnote)

  }
  
}
