import Foundation
@MainActor
enum MeasurmentFormatterManager {
  static let formatter = MeasurementFormatter()

  static func buildTemperatureDescription(high: Measurement<UnitTemperature>, low: Measurement<UnitTemperature>) -> String {
    "最高\(formatter.string(from: high))， 最低\(formatter.string(from: low))"
  }
}
