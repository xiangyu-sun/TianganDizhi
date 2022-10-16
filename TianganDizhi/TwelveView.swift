//
//  TwelveView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 15/10/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct TwelveView: View {
    
    let data = Dizhi.allCases
    
    let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        
        ScrollView {
            GeometryReader { gp in
                LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
                    ForEach(data, id: \.self) { item in
                        DizhiGridView(dizhi: item)
                            .frame(width: gp.size.width / 3)
                            .border(Color.primary)
                    }
                }
            }
            .padding()
        }
    }
}

struct TwelveView_Previews: PreviewProvider {
    static var previews: some View {
        TwelveView()
    }
}
