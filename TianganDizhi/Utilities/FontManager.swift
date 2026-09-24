//
//  FontManager.swift
//  TianganDizhi
//
//  Created by Claude Code
//

#if os(iOS)
import UIKit
#endif
import Foundation
import os

// MARK: - FontManager

enum FontManager {
    static let customFontName = "Weibei TC Bold"
    private static let logger = Logger(subsystem: "com.uriphium.Tiangandizhi.FontManager", category: "Font")
    
    #if os(iOS)
    /// Safely loads UIFont with fallback to system font
    /// - Parameter size: The desired font size
    /// - Returns: Custom font if available, otherwise system bold font
    static func safeUIFont(size: CGFloat) -> UIFont {
        if let customFont = UIFont(name: customFontName, size: size) {
            return customFont
        }
        logger.warning("Custom font '\(customFontName)' not found, using system font")
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    #endif
    
}
