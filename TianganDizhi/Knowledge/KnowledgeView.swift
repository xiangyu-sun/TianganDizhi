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
                NavigationLink(destination: DizhiListView( disppayMode: .name)) {
                    Text(DizhiListView.DisplayMode.name.title)
                }
                NavigationLink(destination: DizhiListView( disppayMode: .zodiac)) {
                    Text(DizhiListView.DisplayMode.zodiac.title)
                }
                NavigationLink(destination: DizhiListView( disppayMode: .time)) {
                    Text(DizhiListView.DisplayMode.time.title)
                }
                NavigationLink(destination: DizhiListView( disppayMode: .month)) {
                    Text(DizhiListView.DisplayMode.month.title)
                }
                NavigationLink(destination: DizhiListView( disppayMode: .organs)) {
                    Text(DizhiListView.DisplayMode.organs.title)
                }
                NavigationLink(destination: DizhiListView( disppayMode: .lvlv)) {
                    Text(DizhiListView.DisplayMode.lvlv.title)
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
