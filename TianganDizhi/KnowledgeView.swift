//
//  KnowledgeView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI

struct KnowledgeView: View {
    var body: some View {
        NavigationView() {
            List() {
                NavigationLink(destination: TianganListView()) {
                    Text("十天干")
                }
                NavigationLink(destination: DizhiListView(disppayMode: .name)) {
                    Text(DizhiListView.DisplayMode.name.title)
                }
                NavigationLink(destination: DizhiListView(disppayMode: .time)) {
                    Text(DizhiListView.DisplayMode.time.title)
                }
                NavigationLink(destination: DizhiListView(disppayMode: .month)) {
                    Text(DizhiListView.DisplayMode.month.title)
                }
                NavigationLink(destination: DizhiListView(disppayMode: .organs)) {
                    Text(DizhiListView.DisplayMode.organs.title)
                }
            }.navigationBarTitle("天干地支相關知識")
        }
    }
}

struct KnowledgeView_Previews: PreviewProvider {
    static var previews: some View {
        KnowledgeView()
    }
}
