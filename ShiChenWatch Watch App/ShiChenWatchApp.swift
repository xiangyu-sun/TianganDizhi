//
//  ShichenWatchApp.swift
//  ShichenWatch Watch App
//
//  Created by Xiangyu Sun on 23/6/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI

@main
struct ShichenWatch_Watch_AppApp: App {
  @StateObject private var fontProvider = FontProvider()
  @StateObject private var router = AppRouter()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(SettingsManager.shared)
        .environmentObject(fontProvider)
        .environmentObject(router)
    }
  }
}
