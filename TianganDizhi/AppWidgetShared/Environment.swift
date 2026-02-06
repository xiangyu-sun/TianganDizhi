//
//  Environment.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 22/10/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI

extension String {
  static let weibeiBold = "Weibei TC Bold"
}

extension Font {
  static let weiBeiLargeTitle: Font = .custom(.weibeiBold, size: 50, relativeTo: .largeTitle)
  static let weiBeiTitle: Font = .custom(.weibeiBold, size: 40, relativeTo: .title)
  static let weiBeiTitle2: Font = .custom(.weibeiBold, size: 30, relativeTo: .title2)
  static let weiBeiTitle3: Font = .custom(.weibeiBold, size: 24, relativeTo: .title3)
  static let weiBeiBody: Font = .custom(.weibeiBold, size: 22, relativeTo: .body)
  static let weiBeiCallOut: Font = .custom(.weibeiBold, size: 18, relativeTo: .callout)
  static let weiBeiHeadline: Font = .custom(.weibeiBold, size: 20, relativeTo: .headline)
  static let weiBeiFootNote: Font = .custom(.weibeiBold, size: 12, relativeTo: .footnote)

  static let weiBeiTitleWatch: Font = .custom(.weibeiBold, size: 28, relativeTo: .title)
}

// MARK: - Font Environment Keys
// Note: These are now simple storage keys. FontProvider handles font selection logic.

private struct TitleFontEnvironmentKey: EnvironmentKey {
  #if os(watchOS)
  static let defaultValue: Font = .weiBeiTitleWatch
  #else
  static let defaultValue: Font = .weiBeiTitle
  #endif
}

private struct LargeTitleFontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = .weiBeiLargeTitle
}

private struct BodyFontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = .weiBeiBody
}

private struct CalloutFontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = .weiBeiCallOut
}

private struct FootnoteFontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = .weiBeiFootNote
}

private struct HeadlineFontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = .weiBeiHeadline
}

private struct Title3FontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = .weiBeiTitle3
}

private struct Title2FontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = .weiBeiTitle2
}


// MARK: - ShouldScaleFontEnvironmentKey

private struct ShouldScaleFontEnvironmentKey: EnvironmentKey {
  static var defaultValue: Bool {
    #if os(iOS)
    UIScreen.main.bounds.width > 744
    #else
    false
    #endif
  }

}

extension EnvironmentValues {

  var titleFont: Font {
    get { self[TitleFontEnvironmentKey.self] }
    set { self[TitleFontEnvironmentKey.self] = newValue }
  }

  var largeTitleFont: Font {
    get { self[LargeTitleFontEnvironmentKey.self] }
    set { self[LargeTitleFontEnvironmentKey.self] = newValue }
  }

  var title2Font: Font {
    get { self[Title2FontEnvironmentKey.self] }
    set { self[Title2FontEnvironmentKey.self] = newValue }
  }

  var title3Font: Font {
    get { self[Title3FontEnvironmentKey.self] }
    set { self[Title3FontEnvironmentKey.self] = newValue }
  }

  var bodyFont: Font {
    get { self[BodyFontEnvironmentKey.self] }
    set { self[BodyFontEnvironmentKey.self] = newValue }
  }

  var calloutFont: Font {
    get { self[CalloutFontEnvironmentKey.self] }
    set { self[CalloutFontEnvironmentKey.self] = newValue }
  }

  var footnote: Font {
    get { self[FootnoteFontEnvironmentKey.self] }
    set { self[FootnoteFontEnvironmentKey.self] = newValue }
  }

  var headlineFont: Font {
    get { self[HeadlineFontEnvironmentKey.self] }
    set { self[HeadlineFontEnvironmentKey.self] = newValue }
  }

  var shouldScaleFont: Bool {
    get { self[ShouldScaleFontEnvironmentKey.self] }
    set { }
  }

}

// MARK: - Removed broken iPad view modifiers
// These modifiers were ignoring the passed-in parameter on non-iPad devices.
// Font injection now happens at the root level via FontProvider.

