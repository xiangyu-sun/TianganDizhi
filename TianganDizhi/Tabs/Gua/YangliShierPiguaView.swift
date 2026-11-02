//
//  ShierPiguaView 2.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 21/4/25.
//  Copyright © 2025 孙翔宇. All rights reserved.
//

import Bagua
import ChineseAstrologyCalendar
import ChineseTranditionalMusicCore
import MusicTheory
import SwiftUI

// MARK: - YangliShierPiguaView

struct YangliShierPiguaView: View {

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

          if jieqi.rawValue.isMultiple(of: 2) {
            let dizhi = Dizhi(rawValue: (jieqi.rawValue / 2) + 1) ?? .chen
            let dizhiIndex = dizhi.rawValue - 1

            let monthIndex = jieqi.monthFromCelestialLongitude
            let monthName = localizedMonthName(from: monthIndex, language: displayLanguage) ?? ""

            Text(monthName)
              .rotationEffect(getRotatingAngle(for: dizhiIndex, base: 12))
              .offset(angle12Position(for: dizhiIndex, in: size, z: 1))

            let gua = ShierPiguas[dizhiIndex]
            HStack {
              if shouldScaleFont {
                Text(gua.symbol)
              }
              Text(gua.localizedName(in: displayLanguage.glyphLanguage))
            }
            .rotationEffect(getRotatingAngle(for: dizhiIndex - 1, base: 12))
            .offset(angle12Position(for: dizhiIndex - 1, in: size, z: 2))
          }
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
    .navigationTitle("陽曆十二辟卦")
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

  /// How far each ring sits in from the rim, outermost first: 節氣, month, 卦.
  var ringInsets: [Double] {
    #if os(watchOS)
    [12, 30, 48]
    #else
    shouldScaleFont ? [46, 126, 206] : [28, 80, 126]
    #endif
  }

  /// The 卦 ring's radius at the dial's natural size; see `ShierPiguaView.hubRadius`.
  var hubRadius: Double {
    #if os(watchOS)
    20
    #else
    shouldScaleFont ? 20 : 60
    #endif
  }

  /// The month's name in the UI language, not the device region. Chinese keeps the full
  /// 九月 form; other languages use the short form (Sep), since the ring has room for
  /// about two glyphs.
  func localizedMonthName(from number: Int, language: DisplayLanguage) -> String? {
    guard (1...12).contains(number) else { return nil }

    var dateComponents = DateComponents()
    dateComponents.month = number
    let calendar = Calendar(identifier: .gregorian)

    if let date = calendar.date(from: dateComponents) {
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: language.identifier)
      formatter.dateFormat = language.isChinese ? "LLLL" : "LLL"
      return formatter.string(from: date)
    }

    return nil
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
  YangliShierPiguaView()
}
