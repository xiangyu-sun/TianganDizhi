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

// MARK: - ShierPiguaView

struct ShierPiguaView: View {

  // MARK: Internal

  @Environment(\.bodyFont) var bodyFont
  @Environment(\.titleFont) var titleFont
  @Environment(\.footnote) var footnote

  @Environment(\.shouldScaleFont) var shouldScaleFont
  @Environment(\.displayLanguage) var displayLanguage

  @AppStorage(Constants.piGuaRotationEnabled, store: Constants.sharedUserDefault)
  var piGuaRotationEnabled = false

  @State private var rotationOn = false

  var font: Font {
    #if os(watchOS)
    footnote
    #else
    shouldScaleFont ? titleFont : bodyFont
    #endif
  }

  var body: some View {
    GeometryReader { geometry in
      let fit = fitScale(for: geometry.size)
      let size = CGSize(width: geometry.size.width / fit, height: geometry.size.height / fit)
      ZStack {
        ForEach(Jieqi.allCases, id: \.self) { jieqi in
          Text(jieqi.localizedName(in: displayLanguage.glyphLanguage))
            .rotationEffect(getRotatingAngle(for: jieqi.rawValue, base: 24))
            .offset(anglePosition(for: jieqi.rawValue, in: size))

          let dizhi = Dizhi(rawValue: max((jieqi.rawValue + 1) / 2, 1)) ?? .chen
          let dizhiIndex = dizhi.rawValue - 1

          Text(Key.shierLvLvMonthOrder[dizhiIndex].localizedLvlvName(in: displayLanguage.glyphLanguage))
            .rotationEffect(getRotatingAngle(for: dizhiIndex - 3, base: 12))
            .offset(angle12Position(for: dizhiIndex - 3, in: size, z: 1))

          Text(shouldScaleFont ? dizhi.chineseCalendarMonthName : dizhi.chineseCharacter)
            .rotationEffect(getRotatingAngle(for: dizhiIndex - 3, base: 12))
            .offset(angle12Position(for: dizhiIndex - 3, in: size, z: 2))

          let gua = ShierPiguas[dizhiIndex]

          HStack {
            if shouldScaleFont {
              Text(gua.symbol)
            }
            Text(gua.localizedName(in: displayLanguage.glyphLanguage))
          }
          .rotationEffect(getRotatingAngle(for: dizhiIndex - 1, base: 12))
          .offset(angle12Position(for: dizhiIndex - 1, in: size, z: 3))
        }
        .font(font)

        ForEach(0..<12) { index in
          Path { path in
            let segmentAngle = 2 * .pi / Double(12)

            let circleRadius = min(size.width, size.height) / 2
            let center = CGPoint(
              x: size.width * 0.5,
              y: size.height * 0.5) // Adjust center coordinates to match the circle's center
            let angle = 2 * .pi * Double(index) / Double(12) - segmentAngle * 0.5
            let radius: CGFloat = circleRadius

            let endPoint = CGPoint(
              x: center.x + radius * CGFloat(cos(angle)),
              y: center.y + radius * CGFloat(sin(angle)))

            path.move(to: center)
            path.addLine(to: endPoint)
          }
          .stroke(Color.secondary, lineWidth: strokeLineWidth)
        }

        Circle()
          .stroke(lineWidth: circleLineWidth)
          .foregroundStyle(.secondary)
      }

      .frame(width: size.width, height: size.height)
      .scaleEffect(fit)
      .frame(width: geometry.size.width, height: geometry.size.height)
    }
    #if os(watchOS)
    .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
    #endif
    .navigationTitle("十二辟卦")
  }

  var strokeLineWidth: Double {
    #if os(watchOS)
    1
    #else
    2
    #endif
  }

  var circleLineWidth: Double {
    #if os(watchOS)
    1
    #else
    4
    #endif
  }

  /// How far each ring sits in from the rim, outermost first: 節氣, 律呂, 地支, 卦.
  /// On iPhone the steps follow the glyphs rather than a fixed 40 pt: a two-glyph term on
  /// the left or right (穀雨, 蕤賓, 大壯) is ~35 pt wide and needs that much room from the
  /// next ring.
  var ringInsets: [Double] {
    #if os(watchOS)
    [12, 30, 48, 66]
    #else
    shouldScaleFont ? [46, 126, 206, 286] : [28, 74, 112, 150]
    #endif
  }

  /// The 卦 ring's radius at the dial's natural size. Twelve names share that circle with
  /// the spokes, so on iPhone it needs ~70 pt to keep them off the lines. The natural size
  /// then exceeds a phone's width and `fitScale` shrinks the whole dial slightly.
  var hubRadius: Double {
    #if os(watchOS)
    20
    #else
    shouldScaleFont ? 20 : 70
    #endif
  }

  func getRotatingAngle(for index: Int, base: Double) -> Angle {
    if piGuaRotationEnabled {
      let segmentAngle = 2 * .pi / base
      if base == 12 {
        return .init(radians: segmentAngle * Double(index) + .pi * 0.5)

      } else {
        return .init(radians: segmentAngle * Double(index) + .pi * 0.5 - 0.5 * segmentAngle)
      }
    } else {
      return .zero
    }
  }

  // MARK: Private

  /// How much of its natural size the dial can have. The ring offsets are fixed, so an area
  /// smaller than `minimumDiameter` would push the inner rings through the centre; the dial is
  /// laid out at that size and scaled down to fit instead.
  private func fitScale(for size: CGSize) -> CGFloat {
    max(0.2, min(1, min(size.width, size.height) / minimumDiameter))
  }

  /// Twice the innermost ring's inset plus room for its glyphs.
  private var minimumDiameter: CGFloat {
    CGFloat(2 * ((ringInsets.last ?? 0) + hubRadius))
  }

  private func anglePosition(for index: Int, in size: CGSize) -> CGSize {
    let segmentAngle = 2 * .pi / Double(Jieqi.allCases.count)

    let startAngle = segmentAngle * Double(index) + .pi - segmentAngle * 0.5

    let radius = min(size.width, size.height) / 2 - ringInsets[0]
    let x = cos(startAngle) * radius
    let y = sin(startAngle) * radius
    return CGSize(width: x, height: y)
  }

  private func angle12Position(for index: Int, in size: CGSize, z: Double) -> CGSize {
    let segmentAngle = 2 * .pi / Double(12)

    let startAngle = segmentAngle * Double(index) + .pi
    let radius = min(size.width, size.height) / 2 - ringInsets[Int(z)]
    let x = cos(startAngle) * radius
    let y = sin(startAngle) * radius
    return CGSize(width: x, height: y)
  }
}

#Preview {
  ShierPiguaView()
}
