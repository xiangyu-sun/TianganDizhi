//
//  KnowledgeView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct KnowledgeView: View {
    @Environment(\.bodyFont) var bodyFont

    var body: some View {
        NavigationView() {
            List() {
                NavigationLink(destination: TianganListView()) {
                    Text("十天干")
                }
                NavigationLink(destination: DizhiListView(dizhi: Dizhi.allCases, disppayMode: .name)) {
                    Text(DizhiListView.DisplayMode.name.title)
                }
                NavigationLink(destination: DizhiListView(dizhi: Dizhi.orderedAllCases, disppayMode: .zodiac)) {
                    Text(DizhiListView.DisplayMode.zodiac.title)
                }
                NavigationLink(destination: DizhiListView(dizhi: Dizhi.orderedAllCases, disppayMode: .time)) {
                    Text(DizhiListView.DisplayMode.time.title)
                }
                NavigationLink(destination: DizhiListView(dizhi: Dizhi.allCases, disppayMode: .month)) {
                    Text(DizhiListView.DisplayMode.month.title)
                }
                NavigationLink(destination: DizhiListView(dizhi: Dizhi.allCases, disppayMode: .organs)) {
                    Text(DizhiListView.DisplayMode.organs.title)
                }
            }
            .font(bodyFont)
            .navigationBarTitle(Text("天干地支相關知識"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct KnowledgeView_Previews: PreviewProvider {
    static var previews: some View {
        KnowledgeView()
    }
}
