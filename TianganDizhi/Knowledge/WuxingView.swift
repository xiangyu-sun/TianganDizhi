//
//  WuxingView.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 18/11/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import ChineseAstrologyCalendar
import JingluoShuxue
import SwiftUI

// MARK: - WuxingView

struct WuxingView: View {
    
    let columns = [
        GridItem(.flexible(), spacing: 0)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                ForEach(Wuxing.allCases, id: \.self) { item in
                    HStack() {
                        Text("\(item.chineseCharacter)")
                            .font(.title2)
                        
                        HStack(){
                            Text("\(item.tiangan.0.chineseCharactor)")
                            Text("\(item.tiangan.1.chineseCharactor)")
                        }
                        
                        HStack(){
                            ForEach(item.dizhi) {
                                Text("\($0.chineseCharactor)")
                            }
                        }
                        
                        HStack() {
                            let wuzang = 五臟.allCases.first{ $0.wuxing == item } ?? .心
                            Text("\(wuzang.rawValue)")
                            Text("\(wuzang.情緒)")
                        }
                    }
                }
                
                ForEach(五臟.allCases, id: \.self) { item in
                  
                }
      
            }
            .padding()
        }
    }
}

// MARK: - WuxingView_Previews

struct WuxingView_Previews: PreviewProvider {
    static var previews: some View {
        WuxingView()
    }
}
