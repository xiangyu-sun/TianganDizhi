import Foundation
@MainActor
enum MeasurmentFormatterManager {
  static var formatter: MeasurementFormatter =  {
    let formater = MeasurementFormatter()
    
    let numberFormatter = NumberFormatter()
    numberFormatter.maximumFractionDigits = 1 // Hide fractional part
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.numberStyle = .decimal
    formater.numberFormatter = numberFormatter
    return formater
  }()

  static func buildTemperatureDescription(high: Measurement<UnitTemperature>, low: Measurement<UnitTemperature>) -> String {
    "最高\(formatter.string(from: high))， 最低\(formatter.string(from: low))"
  }
}
