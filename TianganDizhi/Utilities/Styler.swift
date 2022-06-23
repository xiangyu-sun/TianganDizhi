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
        if #available(iOS 14.0, *) {
            return .custom("Weibei TC Bold", size: size, relativeTo: .largeTitle)
        } else {
            return .custom("Weibei TC Bold", size: size)
        }
        
    }
    
    public static func defaultTitleWithSize(size: CGFloat) -> Font {
        if #available(iOS 14.0, *) {
            return .custom("Weibei TC Bold", size: size, relativeTo: .title)
        } else {
            return .custom("Weibei TC Bold", size: size)
        }
        
    }
    
    
    public static func defaultBodyWithSize(size: CGFloat) -> Font {
        if #available(iOS 14.0, *) {
            return .custom("Weibei TC Bold", size: size, relativeTo: .body)
        } else {
            return .custom("Weibei TC Bold", size: size)
        }
        
    }
    
    public static var defaultFootnote: Font {
        if #available(iOS 14.0, *) {
            return .custom("Weibei TC Bold", size: 18, relativeTo: .footnote)
        } else {
            return .custom("Weibei TC Bold", size: 18)
        }
        
    }
}
