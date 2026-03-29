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

  @EnvironmentObject var fontProvider: FontProvider
  @EnvironmentObject var settingsManager: SettingsManager
  
  // @State private var liveActivityManager = LiveActivityManager.shared
  // @State private var isTogglingLiveActivity = false
  // @State private var liveActivityError: String?

  var body: some View {
    Form {
      // #if os(iOS)
      // Section(header: Text("靈動島與鎖屏"), footer: Text("靈動島每分鐘更新一次。系統限制靈動島最多顯示12小時，本應用會在11小時後自動重啟以保持持續顯示。")) {
      //   Toggle(isOn: Binding(
      //     get: { liveActivityManager.isActivityRunning },
      //     set: { _ in
      //       Task {
      //         isTogglingLiveActivity = true
      //         liveActivityError = nil
      //         do {
      //           try await liveActivityManager.toggleLiveActivity()
      //         } catch {
      //           liveActivityError = error.localizedDescription
      //         }
      //         isTogglingLiveActivity = false
      //       }
      //     }
      //   )) {
      //     Text("時辰靈動島")
      //   }
      //   .disabled(isTogglingLiveActivity)
      //   
      //   if let error = liveActivityError {
      //     Text(error)
      //       .font(.caption)
      //       .foregroundStyle(.red)
      //   }
      // }
      // #endif
      
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
    .font(fontProvider.bodyFont)
    .navigationTitle(Text("設置"))
    .onChange(of: useSystemFont) { value in
      fontProvider.useSystemFont = value
      settingsManager.useSystemFont = value
      WidgetCenter.shared.reloadAllTimelines()
    }
    .onChange(of: springFestiveBackgroundEnabled) { _ in
      WidgetCenter.shared.reloadAllTimelines()
    }
    .onChange(of: useTranditionalNaming) { _ in
      WidgetCenter.shared.reloadAllTimelines()
    }
    .onChange(of: springFestiveForegroundEnabled) { _ in
      WidgetCenter.shared.reloadAllTimelines()
    }
    .onChange(of: useGTM8) { _ in
      WidgetCenter.shared.reloadAllTimelines()
    }
    .onChange(of: displayMoonPhaseOnWidgets) { _ in
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
}

#Preview {
  SettingsView()
}
