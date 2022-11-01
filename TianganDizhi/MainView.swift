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
    @ObservedObject var updater = DateProvider()
    @Environment(\.titleFont) var titleFont
    @Environment(\.largeTitleFont) var largeTitleFont
    @Environment(\.bodyFont) var bodyFont
    @Environment(\.shouldScaleFont) var shouldScaleFont
    
    var body: some View {
        
        VStack() {
            let shichen = try! GanzhiDateConverter.shichen(updater.currentDate)

            #if os(watchOS)
            HStack() {
                Text((try? GanzhiDateConverter.zodiac(updater.currentDate).rawValue) ?? "")
                Text(updater.currentDate.chineseYearMonthDate)
                Spacer()
            }
            
            CircularContainerView(currentShichen: shichen, padding: -18)
                    .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            #else
            
            HStack() {
                Text((try? GanzhiDateConverter.zodiac(updater.currentDate).rawValue) ?? "")
                    .font(titleFont)
                Text(updater.currentDate.chineseYearMonthDate)
                    .font(titleFont)
                Spacer()
            }
           
            Text(shichen.aliasName)
                .font(largeTitleFont)
            Text(shichen.organReference)
                .font(bodyFont)
            
            if self.shouldScaleFont {
                CircularContainerView(currentShichen: shichen, padding: 0)
            }else {
                CircularContainerView(currentShichen: shichen, padding: 0)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            
            #endif
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
