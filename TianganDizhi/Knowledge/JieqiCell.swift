//
//  JieqiCell.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/8/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI
import ChineseAstrologyCalendar

struct JieqiCell: View {
    @Environment(\.bodyFont) var bodyFont
    @Environment(\.title3Font) var title3Font
    
    let jieqi: Jieqi
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text(jieqi.chineseName)
                    .font(title3Font)
            }
            Text(jieqi.qishierHou)
                .font(bodyFont)
        }
    }
}

struct JieqiCell_Previews: PreviewProvider {
    static var previews: some View {
        JieqiCell(jieqi: .bailu)
    }
}
