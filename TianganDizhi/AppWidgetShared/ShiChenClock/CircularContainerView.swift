//
//  ClockView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/07/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - CircularContainerView

struct CircularContainerView<Centre: View>: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let currentShichen: Dizhi
  let padding: CGFloat
  /// Text in the middle of the dial. It is kept inside the 地支 ring, and shrinks rather than
  /// running into 卯 and 酉 when it is wider (English, larger Dynamic Type, small widgets).
  @ViewBuilder var centre: Centre

  var body: some View {
    ZStack {
      Circle()
        .stroke(lineWidth: 4)
        .foregroundStyle(.secondary)
        .accessibilityHidden(true)
      ShichenView(currentShichen: currentShichen)
        .padding(padding)
    }
    // Treat the whole clock as a single accessible element describing the current shichen
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text("當前時辰：\(currentShichen.chineseCharacter)，\(currentShichen.localizedHourName(in: displayLanguage.glyphLanguage))"))
    .accessibilityAddTraits(.updatesFrequently)
    .overlay {
      GeometryReader { proxy in
        centre
          .lineLimit(1)
          .minimumScaleFactor(0.5)
          .frame(width: proxy.size.width * Self.centreWidthRatio)
          .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
      }
    }
  }

  /// The share of the dial's width the centre may use. The 地支 glyphs sit one glyph in from
  /// the rim, leaving roughly 65–75% free depending on `padding`.
  private static var centreWidthRatio: CGFloat { 0.6 }
}

extension CircularContainerView where Centre == EmptyView {
  init(currentShichen: Dizhi, padding: CGFloat) {
    self.init(currentShichen: currentShichen, padding: padding) { EmptyView() }
  }
}

#Preview {
  CircularContainerView(currentShichen: .chen, padding: 0) {
    VStack {
      Text(verbatim: "Quarter 5").font(.largeTitle)
      Text(verbatim: "Small Intestine")
    }
  }
  .fixedSize(horizontal: false, vertical: true)
}
