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
        List() {
            NavigationLink(destination: TianganListView()) {
                Text("Tiangan")
            }
            NavigationLink(destination: DizhiListView(disppayMode: .name)) {
                Text("Dizhi")
            }
            NavigationLink(destination: DizhiListView(disppayMode: .time)) {
                Text("Dizhi")
            }
        }
    }
}

struct KnowledgeView_Previews: PreviewProvider {
    static var previews: some View {
        KnowledgeView()
    }
}
