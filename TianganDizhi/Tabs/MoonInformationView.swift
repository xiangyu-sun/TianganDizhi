import SwiftUI

// MARK: - MoonInformationView

struct MoonInformationView: View {

  // MARK: Internal

  enum MoonEvent: Equatable {
    case rise(Date)
    case set(Date)
  }

  let info: WeatherData.Information
  @Environment(\.bodyFont) var bodyFont
  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false

  /// WeatherKit legitimately returns only one of moonrise/moonset on some
  /// days (e.g. the moon doesn't set before the day ends), so each must be
  /// orderable and renderable independently rather than a single `if let`
  /// over both suppressing the row whenever either one is nil.
  static func orderedMoonEvents(moonrise: Date?, moonset: Date?) -> [MoonEvent] {
    switch (moonrise, moonset) {
    case let (rise?, set?) where rise > set:
      [.set(set), .rise(rise)]
    case let (rise?, set?):
      [.rise(rise), .set(set)]
    case let (rise?, nil):
      [.rise(rise)]
    case let (nil, set?):
      [.set(set)]
    case (nil, nil):
      []
    }
  }

  var body: some View {
    VStack(alignment: .center) {
      HStack {
        Image(systemName: info.moonPhase.moonPhase.symbolName)
          .accessibilityHidden(true)
        Text(info.moonPhase.name(traditionnal: useTranditionalNaming))
        if let gua = info.moonPhase.gua {
          Text(gua.description)
        }
      }
      .font(bodyFont)
      HStack {
        ForEach(Array(Self.orderedMoonEvents(moonrise: info.moonRise, moonset: info.moonset).enumerated()), id: \.offset) { _, event in
          switch event {
          case .rise(let date): moonriseView(date)
          case .set(let date): moonsetView(date)
          }
        }
      }
    }
    .accessibilityElement(children: .combine)
  }

  // MARK: Private

  private func moonriseView(_ moonrise: Date) -> some View {
    HStack(spacing: 0) {
      Text(moonrise, style: .time)
      Text("月升")
    }
    .font(bodyFont)
    .autoColorPastDate(moonrise)
  }

  private func moonsetView(_ moonset: Date) -> some View {
    HStack(spacing: 0) {
      Text(moonset, style: .time)
      Text("月落")
    }
    .font(bodyFont)
    .autoColorPastDate(moonset)
  }
}

#Preview {
  VStack {
    SunInformationView(
      info: WeatherData.Information(
        moonPhase: .firstQuarter,
        moonRise: .now,
        moonset: .now,
        sunrise: .now,
        sunset: .now,
        noon: .now,
        midnight: .now,
        temperatureHigh: .init(value: 12, unit: .celsius),
        temperatureLow: .init(value: 30, unit: .celsius),
        condition: "ok"))

    MoonInformationView(
      info: WeatherData.Information(
        moonPhase: .firstQuarter,
        moonRise: .now,
        moonset: .now,
        sunrise: .now,
        sunset: .now,
        noon: .now,
        midnight: .now,
        temperatureHigh: .init(value: 12, unit: .celsius),
        temperatureLow: .init(value: 30, unit: .celsius),
        condition: "ok"))
  }
}
