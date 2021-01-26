//
//  MainView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar


struct MainView: View {
    @ObservedObject var updater = Updater.shared
    @Environment(\.titleFont) var titleFont
    @Environment(\.largeTitleFont) var largeTitleFont
    @Environment(\.bodyFont) var bodyFont
    
 
    var body: some View {
 
        VStack() {
                HStack() {
                    Text((try? GanzhiDateConverter.zodiac(updater.date).rawValue) ?? "")
                        .font(titleFont)
                    Text(updater.date.chineseYearMonthDate)
                        .font(titleFont)
                    Spacer()
                }
                
                let shichen = try! GanzhiDateConverter.shichen(updater.date)
                Spacer()
                Text(shichen.aliasName)
                .font(largeTitleFont)
                Text(shichen.organReference)
                .font(bodyFont)
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    ClockView(currentShichen: shichen, padding: 50)
                        .padding()
                } else {
                    ClockView(currentShichen: shichen, padding: 14)
                        .padding()
                }
      
                
                Spacer()
            }
            
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(\.locale, Locale(identifier: "zh_Hant"))
        MainView()
            .environment(\.locale, Locale(identifier: "ja_JP"))
            
    }
}
