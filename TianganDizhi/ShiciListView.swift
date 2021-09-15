//
//  ShiciListView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 9/15/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI

struct ShiciListView: View {
    @Environment(\.bodyFont) var bodyFont

    var body: some View {
        NavigationView() {
            List() {
                NavigationLink(destination: ShiciView()) {
                    Text("十二時辰頌")
                }
            }
            .font(bodyFont)
            .navigationBarTitle(Text("詩詞歌賦頌"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ShiciListView_Previews: PreviewProvider {
    static var previews: some View {
        ShiciListView()
    }
}
