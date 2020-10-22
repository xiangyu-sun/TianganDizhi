//
//  Styler.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 04/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import SwiftUI

extension Font {
    public static var defaultLargeTitle: Font {
        
        if #available(iOS 14.0, *) {
            return .custom("Weibei TC Bold", size: 50, relativeTo: .largeTitle)
        } else {
            return .custom("Weibei TC Bold", size: 50)
        }
        
    }
    
    public static var defaultTitle: Font {
        if #available(iOS 14.0, *) {
            return .custom("Weibei TC Bold", size: 40, relativeTo: .title)
        } else {
            return .custom("Weibei TC Bold", size: 40)
        }
        
    }
    public static var defaultBody: Font {
        if #available(iOS 14.0, *) {
            return .custom("Weibei TC Bold", size: 22, relativeTo: .subheadline)
        } else {
            return .custom("Weibei TC Bold", size: 22)
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
