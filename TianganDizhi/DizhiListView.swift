//
//  DizhiListView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 25/03/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI

struct DizhiListView: View {
    enum DisplayMode {
        case name
        case month
        case time
    }
    
    let dizhi = Dizhi.allCases
    let disppayMode: DisplayMode
    
    var body: some View {
        List(dizhi, id: \.self) {
            
            if self.disppayMode == .name {
                Text($0.displayText)
            } else if self.disppayMode == .name {
                Text($0.displayHourDetailText)
            } else {
                Text($0.displayHourDetailText)
            }
        }
    }
}

struct DizhiListView_Time_Previews: PreviewProvider {
    static var previews: some View {
        DizhiListView(disppayMode: .time)
    }
}

struct DizhiListView_Name_Previews: PreviewProvider {
    static var previews: some View {
        DizhiListView(disppayMode: .name)
    }
}
