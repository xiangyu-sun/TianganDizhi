//
//  JieqiContainerView.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 10/8/21.
//  Copyright © 2021 孙翔宇. All rights reserved.
//

import SwiftUI

struct JieqiContainerView: View {

    let padding: CGFloat

    var body: some View {
        ZStack{
            JieqiCircularView(currentJieqi: nil)
                .scaledToFill()
        }
        .scaledToFit()
        
    }
}

struct JieqiContainerView_Previews: PreviewProvider {
    static var previews: some View {
        JieqiContainerView(padding: 0)
    }
}
