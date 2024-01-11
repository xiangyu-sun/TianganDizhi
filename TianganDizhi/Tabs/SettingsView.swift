//
//  SettingsView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 22/12/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import SwiftUI
import WidgetKit

// MARK: - SettingsView

struct SettingsView: View {
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false
  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false

  @AppStorage(Constants.useTranditionalNaming, store: Constants.sharedUserDefault)
  var useTranditionalNaming = false

  @AppStorage(Constants.displayMoonPhaseOnWidgets, store: Constants.sharedUserDefault)
  var displayMoonPhaseOnWidgets = false

  @AppStorage(Constants.useGTM8, store: Constants.sharedUserDefault)
  var useGTM8 = false

  @AppStorage(Constants.piGuaRotationEnabled, store: Constants.sharedUserDefault)
  var piGuaRotationEnabled = false
  
  @AppStorage(Constants.useSystemFont, store: Constants.sharedUserDefault)
  var useSystemFont = false

  @Environment(\.bodyFont) var bodyFont
  
  @EnvironmentObject var settingsManager: SettingsManager

  var body: some View {
    Form {
      Section(header: Text("春節氣氛組件設置")) {
        Toggle(isOn: $springFestiveBackgroundEnabled) {
          Text("組件紅底")
        }
        Toggle(isOn: $springFestiveForegroundEnabled) {
          Text("組件夜間模式使用黑字")
        }
      }
      Section(header: Text("通用設置")) {
        Toggle(isOn: $useSystemFont) {
          Text("使用系統字體")
        }

        Toggle(isOn: $useGTM8) {
          Text("節日使用中國時區(海外用戶)")
        }

        Toggle(isOn: $displayMoonPhaseOnWidgets) {
          Text("組件顯示月相")
        }

        Toggle(isOn: $useTranditionalNaming) {
          Text("顯示傳統名稱")
        }

        Toggle(isOn: $piGuaRotationEnabled) {
          Text("十二辟卦文字方向配圓弧")
        }
      }
    }
    .font(bodyFont)
    .navigationTitle(Text("設置"))
    .onChange(of: useSystemFont) { value in
      settingsManager.useSystemFont = value
      if #available(watchOS 9.0, iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      } else {
        // Fallback on earlier versions
      }
    }
    .onChange(of: springFestiveBackgroundEnabled) { _ in
      if #available(watchOS 9.0, iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      } else {
        // Fallback on earlier versions
      }
    }
    .onChange(of: useTranditionalNaming) { _ in
      if #available(watchOS 9.0, iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      } else {
        // Fallback on earlier versions
      }
    }
    .onChange(of: springFestiveForegroundEnabled) { _ in
      if #available(watchOS 9.0, iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      } else {
        // Fallback on earlier versions
      }
    }
    .onChange(of: useGTM8) { _ in
      if #available(watchOS 9.0, iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      } else {
        // Fallback on earlier versions
      }
    }
    .onChange(of: displayMoonPhaseOnWidgets) { _ in
      if #available(watchOS 9.0, iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      } else {
        // Fallback on earlier versions
      }
    }
  }
}

// MARK: - SettingsView_Previews

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView()
  }
}
