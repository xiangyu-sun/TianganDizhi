//
//  SettingsView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 22/12/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
  @AppStorage("springFestiveBackgroundEnabled", store: UserDefaults(suiteName: "group.uriphium.tiangandizhi"))
  var springFestiveBackgroundEnabled: Bool = false
  @AppStorage("springFestiveForegroundEnabled") var springFestiveForegroundEnabled: Bool = false

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("春節氣氛組件設置")) {
          Toggle(isOn: $springFestiveBackgroundEnabled) {
            Text("紅底")
          }
          Toggle(isOn: $springFestiveForegroundEnabled) {
            Text("夜間模式也使用黑字")
          }
        }
        
      }
      .navigationBarTitle(Text("設置"))
      .onChange(of: springFestiveBackgroundEnabled) { newValue in
        if #available(watchOS 9.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        } else {
          // Fallback on earlier versions
        }
      }
    }
  }
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
