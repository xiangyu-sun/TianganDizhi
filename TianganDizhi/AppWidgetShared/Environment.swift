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

extension EnvironmentValues {
  #if os(watchOS)
  @Entry var titleFont: Font = .weiBeiTitleWatch
  #else
  @Entry var titleFont: Font = .weiBeiTitle
  #endif
  @Entry var largeTitleFont: Font = .weiBeiLargeTitle
  @Entry var title2Font: Font = .weiBeiTitle2
  @Entry var title3Font: Font = .weiBeiTitle3
  @Entry var bodyFont: Font = .weiBeiBody
  @Entry var calloutFont: Font = .weiBeiCallOut
  @Entry var headlineFont: Font = .weiBeiHeadline
  @Entry var footnote: Font = .weiBeiFootNote
  // Derived from horizontalSizeClass in views that need it; kept for backward compat
  @Entry var shouldScaleFont: Bool = false
}
