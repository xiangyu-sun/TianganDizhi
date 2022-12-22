//
//  SettingsView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 22/12/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI
import WidgetKit

// MARK: - SettingsView

struct SettingsView: View {
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false
  @AppStorage(Constants.springFestiveForegroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveForegroundEnabled = false

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("春節氣氛組件設置")) {
          Toggle(isOn: $springFestiveBackgroundEnabled) {
            Text("紅底")
          }
          Toggle(isOn: $springFestiveForegroundEnabled) {
            Text("夜間模式使用黑字")
          }
        }
      }
      #if os(iOS)
      .navigationBarTitle(Text("設置"))
      #endif
      .onChange(of: springFestiveBackgroundEnabled) { _ in
        if #available(watchOS 9.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        } else {
          // Fallback on earlier versions
        }
      }
      .onChange(of: springFestiveForegroundEnabled) { _ in
        if #available(watchOS 9.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        } else {
          // Fallback on earlier versions
        }
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
