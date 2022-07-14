//
//  Styler.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI

extension Font {
    
    public static func defaultLargeTitleWithSize(size: CGFloat) -> Font {
        return .custom("Weibei TC Bold", size: size, relativeTo: .largeTitle)
    }
    
    public static func defaultTitleWithSize(size: CGFloat) -> Font {
        return .custom("Weibei TC Bold", size: size, relativeTo: .title)
    }
    
    public static func defaultBodyWithSize(size: CGFloat) -> Font {
        return .custom("Weibei TC Bold", size: size, relativeTo: .body)
    }
    
    public static var defaultFootnote: Font {
        return .custom("Weibei TC Bold", size: 18, relativeTo: .footnote)
    }
    
    public static func defaultWidgetBodyWithSize(size: CGFloat) -> Font {
        return .custom("Xingkai TC Light", size: size, relativeTo: .body)
    }
}
