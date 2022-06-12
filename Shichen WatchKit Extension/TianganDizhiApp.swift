//
//  TianganDizhiApp.swift
//  Shichen WatchKit Extension
//
//  Created by 孙翔宇 on 10/16/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI

@main
struct TianganDizhiApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
