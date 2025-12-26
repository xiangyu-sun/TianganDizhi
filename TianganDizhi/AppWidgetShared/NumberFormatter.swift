import Foundation


extension NumberFormatter {
  static var tranditionalChineseNunmberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    formatter.locale = Locale(identifier: "zh-Hant")
    return formatter
  }()
}
