//
//  FontManager.swift
//  TianganDizhi
//
//  Created by Claude Code
//

#if os(iOS)
import UIKit
#endif
import ChineseAstrologyCalendar
import Foundation
import os

// MARK: - FontManager

enum FontManager {
    static var customFontName: String { WeibeiFont.fontName }
    private static let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.FontManager", category: "Font")
    
    #if os(iOS)
    /// Safely loads UIFont with fallback to system font
    /// - Parameter size: The desired font size
    /// - Returns: Custom font if available, otherwise system bold font
    static func safeUIFont(size: CGFloat) -> UIFont {
        // Outside Chinese the calligraphy font only draws the Han glyphs; Latin
        // text uses the system font (see `CalligraphyFont`).
        if !DisplayLanguage.app.isChinese, WeibeiFont.isAvailable {
            let base = UIFont.systemFont(ofSize: size, weight: .bold)
            let cascade = UIFontDescriptor(name: WeibeiFont.postScriptName, size: size)
            let descriptor = base.fontDescriptor.addingAttributes([.cascadeList: [cascade]])
            return UIFont(descriptor: descriptor, size: size)
        }
        if let customFont = UIFont(name: customFontName, size: size) {
            return customFont
        }
        logger.info("Custom font '\(customFontName)' not activated yet, using system font")
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    #endif
    
}
