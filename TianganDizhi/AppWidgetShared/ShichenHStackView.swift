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

// MARK: - ShichenHStackView

struct ShichenHStackView: View {
  let shichen: Dizhi
  @Environment(\.titleFont) var titleFont
  @Environment(\.shouldScaleFont) var shouldScaleFont
  @Environment(\.title2Font) var title2Font
  @Environment(\.widgetFamily) var family

  var body: some View {
    HStack {
      VStack {
        Text("\(shichen.previous.displayHourText)")
        #if os(watchOS)
          .font(title2Font)
        #else
          .font((shouldScaleFont && family != .systemMedium) ? titleFont : title2Font)
        #endif
        ShichenInformationView(shichen: shichen.previous)
      }
      .foregroundColor(Color.secondary)

      Spacer()

      VStack {
        Text("\(shichen.displayHourText)")
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
        Text("\(shichen.next.displayHourText)")
        #if os(watchOS)
          .font(title2Font)
        #else
          .font((shouldScaleFont && family != .systemMedium) ? titleFont : title2Font)
        #endif
        ShichenInformationView(shichen: shichen.next)
      }
      .foregroundColor(Color.secondary)
    }
  }
}

// MARK: - ShichenInformationView

struct ShichenInformationView: View {
  @Environment(\.shouldScaleFont) var shouldScaleFont
  @Environment(\.title2Font) var title2Font
  @Environment(\.widgetFamily) var family

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
      HStack {
        Text(shichen.aliasName)
        Text(shichen.organReference)
      }
      #if os(iOS)
      .font(scaleFont ? title2Font : .defaultFootnote)
      #else
      .font(.defaultFootnote)
      #endif
    }
  }
}

// MARK: - ShichenHStackView_Previews

struct ShichenHStackView_Previews: PreviewProvider {
  static var previews: some View {
    ShichenHStackView(shichen: .zi)
#if os(watchOS)
          .previewContext(WidgetPreviewContext(family: .accessoryInline))
#else
          .previewContext(WidgetPreviewContext(family: .systemMedium))
      #endif
      
  }
}
