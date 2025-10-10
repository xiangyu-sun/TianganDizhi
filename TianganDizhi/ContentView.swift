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

// MARK: - ContentView

struct ContentView: View {

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
    .environment(\.titleFont, settingsManager.useSystemFont ? .title : .weiBeiTitle)
    .environment(\.title2Font, settingsManager.useSystemFont ? .title2 : .weiBeiTitle2)
    .environment(\.title3Font, settingsManager.useSystemFont ? .title3 : .weiBeiTitle3)
    .environment(\.largeTitleFont, settingsManager.useSystemFont ? .largeTitle : .weiBeiLargeTitle)
    .environment(\.bodyFont, settingsManager.useSystemFont ? .body : .weiBeiBody)
    .environment(\.headlineFont, settingsManager.useSystemFont ? .headline : .weiBeiHeadline)
    .environment(\.footnote, settingsManager.useSystemFont ? .footnote : .weiBeiFootNote)
    .environment(\.calloutFont, settingsManager.useSystemFont ? .callout : .weiBeiCallOut)
    #if os(iOS)
    .onAppear {
      if !ProcessInfo.processInfo.arguments.contains("UITestMode") {
        try? AppStoreReviewPrompt(configuration: .init(appID: "1530596254", promoteOnTime: 2)).checkReviewRequest()
      }
    }
    #endif
  }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .environmentObject(SettingsManager.shared)
  }
}
