//
//  MainView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI

// MARK: - MainView

struct MainView: View {
  @ObservedObject var updater = DateProvider()
  @Environment(\.titleFont) var titleFont
  @Environment(\.largeTitleFont) var largeTitleFont
  @Environment(\.bodyFont) var bodyFont
  @Environment(\.shouldScaleFont) var shouldScaleFont

  var body: some View {
    VStack {
      let shichen = try! GanzhiDateConverter.shichen(updater.currentDate)

      #if os(watchOS)
      HStack {
        Text((try? GanzhiDateConverter.zodiac(updater.currentDate).rawValue) ?? "")
        Text(updater.currentDate.chineseYearMonthDate)
      }

      CircularContainerView(currentShichen: shichen, padding: -24)

      #else

      HStack {
        Text((try? GanzhiDateConverter.zodiac(updater.currentDate).rawValue) ?? "")
          .font(titleFont)
        Text(updater.currentDate.chineseYearMonthDate)
          .font(titleFont)
        Spacer()
      }

      Text(shichen.aliasName)
        .font(largeTitleFont)
      Text(shichen.organReference)
        .font(bodyFont)

      if shouldScaleFont {
        CircularContainerView(currentShichen: shichen, padding: 0)
      } else {
        CircularContainerView(currentShichen: shichen, padding: -10)
          .fixedSize(horizontal: false, vertical: true)
          .padding()
      }
      Spacer()

      #endif
    }
    #if os(iOS)
    .background(
      Image("background")
        .resizable(resizingMode: .tile)
        .ignoresSafeArea()
    )
    #endif
  }
}

// MARK: - MainView_Previews

struct MainView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
      .environment(\.locale, Locale(identifier: "zh_Hant"))
    MainView()
      .environment(\.locale, Locale(identifier: "ja_JP"))
  }
}
