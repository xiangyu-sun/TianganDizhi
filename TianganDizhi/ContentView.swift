//
//  ContentView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct ContentView: View {
    
    var body: some View {
        TabView(){
            MainView()
            .tabItem {
                Image(systemName: "clock.fill")
                Text("時辰")
            }
            
            KnowledgeView()
            .tabItem {
                Image(systemName: "moon")
                Text("天干地支")
            }
            
//            JieqiContainerView(padding: 0)
//            .tabItem {
//                Image(systemName: "sun.max.fill")
//                Text("二十四節氣")
//            }
            
            TwelveView()
            .tabItem {
                Image(systemName: "book")
                Text("十二地支匯總")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
