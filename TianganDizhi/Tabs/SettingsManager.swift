import SwiftUI

final class SettingsManager: ObservableObject {

  // MARK: Lifecycle

  init() {
    useSystemFont = Constants.sharedUserDefault?.bool(forKey: Constants.useSystemFont) ?? false
  }

  // MARK: Internal

  @MainActor static let shared = SettingsManager()

  @Published var useSystemFont: Bool
}
