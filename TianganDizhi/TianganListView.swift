//
//  TianganListView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct TianganListView: View {
    let tiangan = Tiangan.allCases
     var body: some View {
         List(tiangan, id: \.self) {
            TianganCell(tiangan: $0)
         }
         .navigationBarTitle("十天干")
     }
}

struct TianganCell: View {
    let tiangan: Tiangan
    var body: some View {
        HStack() {
            Text(tiangan.chineseCharactor)
            Text("(\(tiangan.chineseCharactor.transformToPinyin()))")
        }
        .padding()
        .font(.defaultBody)
    }
}

struct TianganListView_Previews: PreviewProvider {
    static var previews: some View {
        TianganListView()
    }
}
