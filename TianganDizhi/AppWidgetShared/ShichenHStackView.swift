//
//  ShichenHStackView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit
import JingluoShuxue

// MARK: - ShichenHStackView

struct ShichenHStackView: View {
  @Environment(\.displayLanguage) private var displayLanguage
  let shichen: Dizhi
  @Environment(\.titleFont) var titleFont
  @Environment(\.shouldScaleFont) var shouldScaleFont
  @Environment(\.title2Font) var title2Font
  @Environment(\.widgetFamily) var family

  var body: some View {
    HStack {
      VStack {
        Text("\(shichen.previous.localizedHourName(in: displayLanguage.glyphLanguage))")
        #if os(watchOS)
          .font(title2Font)
        #else
          .font((shouldScaleFont && family != .systemMedium) ? titleFont : title2Font)
        #endif
        ShichenInformationView(shichen: shichen.previous)
      }
      .foregroundStyle(Color.secondary)

      Spacer()

      VStack {
        Text("\(shichen.localizedHourName(in: displayLanguage.glyphLanguage))")
        #if os(watchOS)
          .font(title2Font)
        #else
          .font((shouldScaleFont && family != .systemMedium) ? titleFont : title2Font)
        #endif

          .scaleEffect(1.2)
        ShichenInformationView(shichen: shichen)
      }

      Spacer()
      VStack {
        Text("\(shichen.next.localizedHourName(in: displayLanguage.glyphLanguage))")
        #if os(watchOS)
          .font(title2Font)
        #else
          .font((shouldScaleFont && family != .systemMedium) ? titleFont : title2Font)
        #endif
        ShichenInformationView(shichen: shichen.next)
      }
      .foregroundStyle(Color.secondary)
    }
  }
}

// MARK: - ShichenInformationView

struct ShichenInformationView: View {
  @Environment(\.displayLanguage) private var displayLanguage
  @Environment(\.shouldScaleFont) var shouldScaleFont
  @Environment(\.title3Font) var title3Font
  @Environment(\.widgetFamily) var family
  @Environment(\.calloutFont) var calloutFont

  let shichen: Dizhi

  var scaleFont: Bool {
    #if os(iOS)
    if #available(iOSApplicationExtension 15.0, *) {
      return shouldScaleFont && family == .systemExtraLarge
    } else {
      return shouldScaleFont
    }
    #else
    return false
    #endif
  }

  var body: some View {
    if #available(iOSApplicationExtension 15.0, *) {
      (displayLanguage.isChinese
        ? AnyLayout(HStackLayout())
        : AnyLayout(VStackLayout(spacing: 0)))
      {
        Text(shichen.aliasName.converted(to: displayLanguage))
        Text(shichen.luizhu.organText(in: displayLanguage))
          .lineLimit(1)
          .minimumScaleFactor(0.6)
      }
      #if os(iOS)
      .font(scaleFont ? title3Font : calloutFont)
      #else
      .font(calloutFont)
      #endif
    }
  }
}

#Preview {
  ShichenHStackView(shichen: .zi)
}
