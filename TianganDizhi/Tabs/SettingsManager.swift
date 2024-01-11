import SwiftUI

final class SettingsManager: ObservableObject {
  static let shared = SettingsManager()
  @Published
  var useSystemFont: Bool
  
  init() {
    useSystemFont = Constants.sharedUserDefault?.bool(forKey: Constants.useSystemFont) ?? false
  }
}
