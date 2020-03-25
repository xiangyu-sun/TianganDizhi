//
//  TianganListView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI

struct TianganListView: View {
    let tiangan = Tiangan.allCases
     var body: some View {
         List(tiangan, id: \.self) {
             Text($0.displayText)
         }
     }
}

struct TianganListView_Previews: PreviewProvider {
    static var previews: some View {
        TianganListView()
    }
}
