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
    @ObservedObject var updater = Updater.shared
    
    var body: some View {
        TabView(){
            VStack() {
                HStack() {
                    Text((try? GanzhiDateConverter.nian(updater.date).formatedYear) ?? "")
                        .font(.defaultTitle)
                    Text((try? GanzhiDateConverter.zodiac(updater.date).rawValue) ?? "")
                        .font(.defaultTitle)
                    Spacer()
                }
                
                HStack() {
                    Text(DateFormatter.localizedString(from: updater.date, dateStyle: .long, timeStyle: .medium))
                        .font(.body)
                    Spacer()
                }
                
                let shichen = try! GanzhiDateConverter.shichen(updater.date)
                Spacer()
                Text(shichen.aliasName)
                .font(.defaultLargeTitle)
                Text(shichen.organReference)
                .font(.defaultBody)
                ClockView(currentShichen: shichen)
                .padding()
                
                Spacer()
            }
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
