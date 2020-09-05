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
            .tabItem { Text("現在時辰")}
            
            KnowledgeView()
            .tabItem { Text("天干地支相關") }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
