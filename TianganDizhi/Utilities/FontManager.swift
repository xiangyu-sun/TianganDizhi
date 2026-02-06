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

// MARK: - FontManager

enum FontManager {
    static let customFontName = "Weibei TC Bold"
    
    /// Loads and verifies custom fonts are available
    static func loadCustomFonts() {
        #if DEBUG
        // List all available fonts for debugging
        printAvailableFonts()
        
        // Verify our custom font is loaded
        verifyCustomFont()
        #endif
    }
    
    #if os(iOS)
    /// Safely loads UIFont with fallback to system font
    /// - Parameter size: The desired font size
    /// - Returns: Custom font if available, otherwise system bold font
    static func safeUIFont(size: CGFloat) -> UIFont {
        if let customFont = UIFont(name: customFontName, size: size) {
            return customFont
        }
        print("⚠️ Warning: Custom font '\(customFontName)' not found, using system font")
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }
    #endif
    
    #if DEBUG
    private static func verifyCustomFont() {
        #if os(iOS)
        if UIFont(name: customFontName, size: 12) != nil {
            print("✅ Custom font '\(customFontName)' loaded successfully")
        } else {
            print("❌ Failed to load custom font '\(customFontName)'")
            print("Available font names containing 'Weibei':")
            UIFont.familyNames.sorted().forEach { family in
                let fonts = UIFont.fontNames(forFamilyName: family)
                let weibeFonts = fonts.filter { $0.localizedCaseInsensitiveContains("weibei") }
                if !weibeFonts.isEmpty {
                    print("  Family: \(family)")
                    weibeFonts.forEach { font in
                        print("    - \(font)")
                    }
                }
            }
        }
        #endif
    }
    
    private static func printAvailableFonts() {
        #if os(iOS)
        print("📝 Available font families:")
        UIFont.familyNames.sorted().forEach { family in
            print("Font Family: \(family)")
            UIFont.fontNames(forFamilyName: family).forEach { font in
                print("  - \(font)")
            }
        }
        #endif
    }
    #endif
}
