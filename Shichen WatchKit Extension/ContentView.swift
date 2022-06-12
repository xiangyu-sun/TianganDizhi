//
//  ContentView.swift
//  Shichen WatchKit Extension
//
//  Created by 孙翔宇 on 10/16/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct ContentView: View {
    @Environment(\.largeTitleFont) var largeTitleFont
    @Environment(\.bodyFont) var bodyFont
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State var date: Date = Date()
    
    
    var body: some View {
        let shichen = try! GanzhiDateConverter.shichen(date)
        
        VStack() {
            titleView
                .padding()
            
            Text(shichen.displayHourText)
                .font(largeTitleFont)
                .padding()
            
            ShichenInformationView(shichen: shichen)
                .padding()
        }
        .onReceive(timer) { input in
            date = input
        }
    }
    
    private var titleView: some View {
        HStack(){
            Text((try? GanzhiDateConverter.nian(date).formatedYear) ?? "")
                .font(bodyFont)
            Text((try? GanzhiDateConverter.zodiac(date).rawValue) ?? "")
                .font(bodyFont)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
