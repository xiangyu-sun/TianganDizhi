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

    var body: some View {
        VStack() {
            HStack() {
                Text((try? GanzhiDateConverter.nian(updater.date).formatedYear) ?? "")
                    .font(.defaultTitle)
                Text((try? GanzhiDateConverter.zodiac(updater.date).rawValue) ?? "")
                    .font(.defaultTitle)
                Spacer()
            }
           
            HStack() {
                Text(Locale.current.languageCode ?? "")
                Text(DateFormatter.localizedString(from: updater.date, dateStyle: .long, timeStyle: .medium))
                    .font(.defaultFootnote)
                Spacer()
            }
            
            let shichen = try! GanzhiDateConverter.shichen(updater.date)
            Spacer()
            Text(shichen.aliasName)
            .font(.defaultLargeTitle)
            Text(shichen.organReference)
            .font(.defaultBody)
            
            ClockView(currentShichen: shichen, padding: 14)
            .padding()
            
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
