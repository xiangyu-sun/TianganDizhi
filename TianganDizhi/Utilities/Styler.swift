//
//  Styler.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI

extension Font {

  public static var defaultFootnote: Font {
    .custom(.weibeiBold, size: 18, relativeTo: .footnote)
  }

  public static func defaultLargeTitleWithSize(size: CGFloat) -> Font {
    .custom(.weibeiBold, size: size, relativeTo: .largeTitle)
  }

  public static func defaultTitleWithSize(size: CGFloat) -> Font {
    .custom(.weibeiBold, size: size, relativeTo: .title)
  }

  public static func defaultBodyWithSize(size: CGFloat) -> Font {
    .custom(.weibeiBold, size: size, relativeTo: .body)
  }
}
