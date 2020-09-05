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
                    Text("十二地支")
                }
                NavigationLink(destination: DizhiListView(disppayMode: .time)) {
                    Text("地支時辰")
                }
                NavigationLink(destination: DizhiListView(disppayMode: .organs)) {
                    Text("時辰與經絡")
                }
            }
        }
    }
}

struct KnowledgeView_Previews: PreviewProvider {
    static var previews: some View {
        KnowledgeView()
    }
}
