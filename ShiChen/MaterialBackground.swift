//
//  MaterialBackground.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 22/12/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI

struct MarbleWidgetBackground: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  @AppStorage(Constants.backgroundStyle, store: Constants.sharedUserDefault)
  var backgroundStyle = 0

  // Day-of-year seed: texture shifts each day, stays consistent within a day
  private var seed: Float {
    let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
    return Float(day) * 7.53
  }

  func body(content: Content) -> some View {
    content.containerBackground(for: .widget) {
      GeometryReader { geo in
        let isDark: Float = colorScheme == .dark ? 1.0 : 0.0
        Rectangle()
          .colorEffect(
            backgroundStyle == 1
              ? ShaderLibrary.stoneMarble(.float2(geo.size.width, geo.size.height), .float(isDark), .float(seed))
              : ShaderLibrary.marble(.float2(geo.size.width, geo.size.height), .float(isDark), .float(seed))
          )
      }
    }
  }
}

extension View {
  func materialBackgroundWidget() -> some View {
    modifier(MarbleWidgetBackground())
  }
}
