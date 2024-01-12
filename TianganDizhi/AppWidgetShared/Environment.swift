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

// MARK: - TitleFontEnvironmentKey

private struct TitleFontEnvironmentKey: EnvironmentKey {
  #if os(watchOS)
  static let defaultValue: Font = SettingsManager.shared.useSystemFont ? .title : .weiBeiTitleWatch
  #else
  static let defaultValue: Font = SettingsManager.shared.useSystemFont ? .title.bold() : .weiBeiTitle
  #endif
}

// MARK: - LargeTitleFontEnvironmentKey

private struct LargeTitleFontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = SettingsManager.shared.useSystemFont ? .largeTitle.bold() : .weiBeiLargeTitle
}

// MARK: - BodyFontEnvironmentKey

private struct BodyFontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = SettingsManager.shared.useSystemFont ? .body.bold() : .weiBeiBody
}

// MARK: - CalloutFontEnvironmentKey

private struct CalloutFontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = SettingsManager.shared.useSystemFont ? .callout.bold() : .weiBeiCallOut
}

// MARK: - FootnoteFontEnvironmentKey

private struct FootnoteFontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = SettingsManager.shared.useSystemFont ? .footnote.bold() : .weiBeiFootNote
}


// MARK: - HeadlineFontEnvironmentKey

private struct HeadlineFontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = SettingsManager.shared.useSystemFont ? .headline.bold() : .weiBeiHeadline
}

// MARK: - Title3FontEnvironmentKey

private struct Title3FontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = SettingsManager.shared.useSystemFont ? .title3.bold() :.weiBeiTitle3
}

// MARK: - Title2FontEnvironmentKey

private struct Title2FontEnvironmentKey: EnvironmentKey {
  static let defaultValue: Font = SettingsManager.shared.useSystemFont ? .title2.bold() : .weiBeiTitle2
}

// MARK: - iPadEnvironmentKey

private struct iPadEnvironmentKey: EnvironmentKey {
  static var defaultValue: Bool {
    #if os(iOS)
    UIDevice.current.userInterfaceIdiom == .pad
    #else
    false
    #endif
  }
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

  var iPad: Bool {
    get { self[iPadEnvironmentKey.self] }
    set { }
  }

  var shouldScaleFont: Bool {
    get { self[ShouldScaleFontEnvironmentKey.self] }
    set { }
  }

}

extension View {
  func titleFont(_ myCustomValue: Font) -> some View {
    #if os(iOS)
    if UIDevice.current.userInterfaceIdiom == .pad {
      return environment(\.titleFont, myCustomValue)
    }
    #endif

    return environment(\.titleFont, TitleFontEnvironmentKey.defaultValue)
  }

  func title3Font(_ myCustomValue: Font) -> some View {
    #if os(iOS)
    if UIDevice.current.userInterfaceIdiom == .pad {
      return environment(\.title3Font, myCustomValue)
    }
    #endif
    return environment(\.title3Font, Title3FontEnvironmentKey.defaultValue)
  }

  func largeTitleFont(_ myCustomValue: Font) -> some View {
    #if os(iOS)
    if UIDevice.current.userInterfaceIdiom == .pad {
      return environment(\.largeTitleFont, myCustomValue)
    }
    #endif
    return environment(\.largeTitleFont, LargeTitleFontEnvironmentKey.defaultValue)
  }

  func bodyFont(_ myCustomValue: Font) -> some View {
    #if os(iOS)
    if UIDevice.current.userInterfaceIdiom == .pad {
      return environment(\.bodyFont, myCustomValue)
    }
    #endif
    return environment(\.bodyFont, BodyFontEnvironmentKey.defaultValue)
  }

  func headlineFont(_ myCustomValue: Font) -> some View {
    #if os(iOS)
    if UIDevice.current.userInterfaceIdiom == .pad {
      return environment(\.headlineFont, myCustomValue)
    }
    #endif
    return environment(\.headlineFont, HeadlineFontEnvironmentKey.defaultValue)
  }

}
