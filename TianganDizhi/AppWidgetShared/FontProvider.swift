//
//  FontProvider.swift
//  TianganDizhi
//

import Combine
@preconcurrency import SwiftUI

// MARK: - FontProvider

@MainActor
final class FontProvider: ObservableObject {

  // MARK: - Published Properties

  @Published var useSystemFont: Bool {
    didSet {
      Constants.sharedUserDefault?.set(useSystemFont, forKey: Constants.useSystemFont)
    }
  }

  // MARK: - Private Properties

  nonisolated(unsafe) private var defaultsObserver: NSObjectProtocol?

  // MARK: - Initialization

  init() {
    self.useSystemFont = Constants.sharedUserDefault?.bool(forKey: Constants.useSystemFont) ?? false

    defaultsObserver = NotificationCenter.default.addObserver(
      forName: UserDefaults.didChangeNotification,
      object: Constants.sharedUserDefault,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor [weak self] in
        guard let self else { return }
        let newValue = Constants.sharedUserDefault?.bool(forKey: Constants.useSystemFont) ?? false
        if self.useSystemFont != newValue {
          self.useSystemFont = newValue
        }
      }
    }
  }

  deinit {
    if let observer = defaultsObserver {
      NotificationCenter.default.removeObserver(observer)
    }
  }

  // MARK: - Computed Font Properties

  var titleFont: Font {
    #if os(watchOS)
    useSystemFont ? .title.bold() : .weiBeiTitleWatch
    #else
    useSystemFont ? .title.bold() : .weiBeiTitle
    #endif
  }

  var largeTitleFont: Font {
    useSystemFont ? .largeTitle.bold() : .weiBeiLargeTitle
  }

  var bodyFont: Font {
    useSystemFont ? .body.bold() : .weiBeiBody
  }

  var calloutFont: Font {
    useSystemFont ? .callout.bold() : .weiBeiCallOut
  }

  var footnoteFont: Font {
    useSystemFont ? .footnote.bold() : .weiBeiFootNote
  }

  var headlineFont: Font {
    useSystemFont ? .headline.bold() : .weiBeiHeadline
  }

  var title2Font: Font {
    useSystemFont ? .title2.bold() : .weiBeiTitle2
  }

  var title3Font: Font {
    useSystemFont ? .title3.bold() : .weiBeiTitle3
  }
}
