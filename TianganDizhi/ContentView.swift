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
        
        VStack() {
            HStack() {
                Text(DateFormatter.localizedString(from: updater.date, dateStyle: .long, timeStyle: .medium))
                    .font(.body)
                Spacer()
            }.padding()
            HStack() {
                
                Text((try? GanzhiDateConverter.nian(updater.date).formatedYear) ?? "")
                    .font(.largeTitle)
                Text((try? GanzhiDateConverter.zodiac(updater.date).rawValue) ?? "")
                    .font(.largeTitle)
                Spacer()
            }.padding()
            Spacer()
            ClockView(currentShichen: try! GanzhiDateConverter.shichen(updater.date))
                .padding()
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
