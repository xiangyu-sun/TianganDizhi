//
//  File.swift
//  
//
//  Created by 孙翔宇 on 25/03/2020.
//

import Foundation

public enum Tiangan: String, CaseIterable {
    case jia, yi, bing, ding, wu, ji, geng, xin, ren, kui
    
    public var displayText: String {
        switch self {
        case .jia:
            return "甲"
        case .yi:
            return "乙"
        case .bing:
            return "丙"
        case .ding:
            return "丁"
        case .wu:
            return "戊"
        case .ji:
            return "己"
        case .geng:
            return "庚"
        case .xin:
            return "辛"
        case .ren:
            return "壬"
        case .kui:
            return "癸"
        }
    }
}

public extension Date {
    
    var year: String {
        let calendar = Calendar(identifier: .chinese)
        
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateStyle = .long
        let regex = try? NSRegularExpression(pattern: ##"(\w*)-(\w*)"##)
        let str = formatter.string(from: self)
        let matches = regex?.matches(in: str, options: [], range: NSRange(location: 0, length: str.count))
        
        var tiangan: String?
        var dizhi: String?
        
        matches?.forEach { (result) in
            let ns = (str as NSString)
            tiangan = ns.substring(with: result.range(at: 1))
            dizhi = ns.substring(with: result.range(at: 2))
        }
        
        var tianGanDizhi: String?
        var zodiac: Zodiac?
        if let tiangan = tiangan, let t = Tiangan(rawValue: tiangan), let dizhi = dizhi, let d = Dizhi(rawValue: dizhi){
            tianGanDizhi = t.displayText + d.displayText
            zodiac = Zodiac(d)
        }
        
        if let tianGanDizhi = tianGanDizhi, let zodiac = zodiac{
            return "\(tianGanDizhi) \(zodiac.rawValue) 年"
        }
        
        return "未卜"
    }
    
    var shichen: String {
        
        let calendar = Calendar(identifier: .chinese)
        
        let component = calendar.dateComponents(in: TimeZone.current, from: Date())
        
        
        
        guard let hour = component.hour else { return "未卜" }
        
        
        return Dizhi(hourOfDay: hour).displayHourText
    }
}
