//
//  JIeqiListView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/8/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct JieqiListView: View {
    var body: some View {
        List(Jieqi.allCases, id: \.self) {jieqi in
            JieqiCell(jieqi: jieqi)
        }
    }
}

struct JIeqiListView_Previews: PreviewProvider {
    static var previews: some View {
        JieqiListView()
    }
}
