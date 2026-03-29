//
//  ContentView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
#if canImport(AppStoreReviewPrompt)
import AppStoreReviewPrompt
#endif
#if os(iOS)
import UIKit
#endif

// MARK: - ContentView

struct ContentView: View {

  @EnvironmentObject var fontProvider: FontProvider
  @EnvironmentObject var settingsManager: SettingsManager

  var body: some View {
    TabView {
      MainView()
        .tabItem {
          Image(systemName: "clock.fill")
          Text("時辰")
        }

      KnowledgeView()
        .tabItem {
          Image(systemName: "moon.stars.fill")
          Text("天干地支")
        }

      GuaListView()
        .tabItem {
          Image(systemName: "sun.max.fill")
          Text("卦")
        }

      ChartListView()
        .tabItem {
          Image(systemName: "chart.bar.xaxis")
          Text("綜合圖示")
        }

      SettingsView()
        .tabItem {
          Image(systemName: "gear.circle.fill")
          Text("設置")
        }
    }
    .environment(\.titleFont, fontProvider.titleFont)
    .environment(\.title2Font, fontProvider.title2Font)
    .environment(\.title3Font, fontProvider.title3Font)
    .environment(\.largeTitleFont, fontProvider.largeTitleFont)
    .environment(\.bodyFont, fontProvider.bodyFont)
    .environment(\.headlineFont, fontProvider.headlineFont)
    .environment(\.footnote, fontProvider.footnoteFont)
    .environment(\.calloutFont, fontProvider.calloutFont)
    #if os(iOS)
    .onAppear {
      applyUIKitFontAppearance(useSystemFont: fontProvider.useSystemFont)
      if !ProcessInfo.processInfo.arguments.contains("UITestMode") {
        try? AppStoreReviewPrompt(configuration: .init(appID: "1530596254", promoteOnTime: 2)).checkReviewRequest()
      }
    }
    .onChange(of: fontProvider.useSystemFont) { newValue in
      applyUIKitFontAppearance(useSystemFont: newValue)
    }
    #endif
  }

  #if os(iOS)
  private func applyUIKitFontAppearance(useSystemFont: Bool) {
    if useSystemFont {
      UINavigationBar.appearance().largeTitleTextAttributes = [
        .font: UIFont.systemFont(ofSize: 34, weight: .bold)
      ]
      UITabBarItem.appearance().setTitleTextAttributes(
        [.font: UIFont.systemFont(ofSize: 12, weight: .medium)], for: []
      )
    } else {
      UINavigationBar.appearance().largeTitleTextAttributes = [
        .font: FontManager.safeUIFont(size: 34)
      ]
      UITabBarItem.appearance().setTitleTextAttributes(
        [.font: FontManager.safeUIFont(size: 12)], for: []
      )
    }
  }
  #endif
}

#Preview {
  ContentView()
    .environmentObject(FontProvider())
    .environmentObject(SettingsManager.shared)
}
