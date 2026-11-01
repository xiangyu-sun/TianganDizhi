import Foundation
@MainActor
enum MeasurmentFormatterManager {
  static var formatter: MeasurementFormatter = {
    let formater = MeasurementFormatter()

    let numberFormatter = NumberFormatter()
    numberFormatter.maximumFractionDigits = 1 // Hide fractional part
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.numberStyle = .decimal
    formater.numberFormatter = numberFormatter
    return formater
  }()

  static func buildTemperatureDescription(high: Measurement<UnitTemperature>, low: Measurement<UnitTemperature>) -> String {
    let high = formatter.string(from: high)
    let low = formatter.string(from: low)
    return String(localized: "最高\(high)最低\(low)", comment: "Today's temperature range; %1$@ high, %2$@ low")
  }
}
