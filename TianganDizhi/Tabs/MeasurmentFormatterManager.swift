import Foundation
struct MeasurmentFormatterManager {
  static let formatter = MeasurementFormatter()
  
  static func buildTemperatureDescription(high: Measurement<UnitTemperature>, low: Measurement<UnitTemperature>) -> String {
    "今日最高溫度\(self.formatter.string(from: high))， 最低溫度\(self.formatter.string(from: low))"
  }
}
