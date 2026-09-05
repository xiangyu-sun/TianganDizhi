//
//  ChinesePinyin.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 07/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import Foundation

extension String {
  /// Returns the pinyin transliteration, or the original string unchanged if
  /// the transform fails (`CFStringTransform`'s `Bool` result was previously
  /// discarded, so a failure silently returned the untransformed Han string
  /// as if it were pinyin, with no way for a caller to tell).
  func transformToPinyin() -> String {
    let stringref = NSMutableString(string: self) as CFMutableString
    guard CFStringTransform(stringref, nil, kCFStringTransformToLatin, false) else {
      return self
    }
    return stringref as String
  }
}
