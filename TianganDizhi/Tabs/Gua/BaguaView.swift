//
//  ShierPiguaView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/8/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import Bagua
import ChineseAstrologyCalendar
import ChineseTranditionalMusicCore
import MusicTheory
import SwiftUI

// MARK: - BaguaView

struct BaguaView: View {

  // MARK: Internal

  struct ViewData {
    let guas: [Trigram]
    let title: String
  }

  @Environment(\.bodyFont) var bodyFont
  @Environment(\.titleFont) var titleFont
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.footnote) var footnote

  let viewData: ViewData

  @State private var rotationOn = false

  var font: Font {
    #if os(watchOS)
    footnote
    #else
    largeTitleFont
    #endif
  }

  var body: some View {
    GeometryReader { geometry in
      let fit = fitScale(for: geometry.size)
      let size = CGSize(width: geometry.size.width / fit, height: geometry.size.height / fit)
      ZStack {
        ForEach(viewData.guas.indices, id: \.self) { index in
          let gua = viewData.guas[index]

          Text(gua.chineseCharacter)
            .offset(anglePosition(for: index, in: size, z: 0))
            .font(font)
            .accessibilityHidden(true)

          Text(gua.symbol)
            .rotationEffect(getRotatingAngle(for: index, base: 8))
            .offset(anglePosition(for: index, in: size, z: 1))
            .font(font.bold())
            .accessibilityHidden(true)

          Text(gua.xiang)
            .offset(anglePosition(for: index, in: size, z: 2))
            .font(bodyFont)
            .accessibilityHidden(true)
        }
      }
      .frame(width: size.width, height: size.height)
      .scaleEffect(fit)
      .frame(width: geometry.size.width, height: geometry.size.height)
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(viewData.title + "：" + viewData.guas.map { "\($0.chineseCharacter)\($0.xiang)" }.joined(separator: "、"))
    }
    #if os(watchOS)
    .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
    #endif
    .navigationTitle(viewData.title)
  }

  var outterSpacing: Double {
    #if os(watchOS)
    12
    #else
    46
    #endif
  }

  var innerSpacing: Double {
    #if os(watchOS)
    18
    #else
    60
    #endif
  }

  func getRotatingAngle(for index: Int, base: Double) -> Angle {
    let segmentAngle = 2 * .pi / base
    return .init(radians: segmentAngle * Double(index))
  }

  // MARK: Private

  /// How much of its natural size the dial can have. The ring offsets are fixed, so an area
  /// smaller than `minimumDiameter` would push the inner rings through the centre; the dial is
  /// laid out at that size and scaled down to fit instead.
  private func fitScale(for size: CGSize) -> CGFloat {
    max(0.2, min(1, min(size.width, size.height) / minimumDiameter))
  }

  /// Twice the outermost ring's offset plus room for the innermost ring's glyphs.
  private var minimumDiameter: CGFloat {
    CGFloat(2 * (outterSpacing + 2 * innerSpacing + 20))
  }

  private func anglePosition(for index: Int, in size: CGSize, z: Double) -> CGSize {
    let segmentAngle = 2 * .pi / Double(viewData.guas.count)

    let startAngle = segmentAngle * Double(index) - .pi * 0.5
    let adjustment = outterSpacing + z * innerSpacing
    let radius = min(size.width, size.height) / 2 -
      adjustment // Adjust the spacing between the circle and the Text elements here
    let x = cos(startAngle) * radius
    let y = sin(startAngle) * radius
    return CGSize(width: x, height: y)
  }

}

#Preview {
  BaguaView(viewData: .init(guas: xiantianBagua, title: "先天八卦"))
}

#Preview {
  BaguaView(viewData: .init(guas: houtianBagua, title: "後天八卦"))
}
