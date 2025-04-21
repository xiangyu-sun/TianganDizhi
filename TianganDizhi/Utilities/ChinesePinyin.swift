//
//  ChinesePinyin.swift
//  TianganDizhi
//
//  Created by 孙翔宇 on 07/09/2020.
//  Copyright © 2020 孙翔宇. All rights reserved.
//

import Foundation

extension String {
  func transformToPinyin() -> String {
    let stringref = NSMutableString(string: self) as CFMutableString
    CFStringTransform(stringref, nil, kCFStringTransformToLatin, false)
    return stringref as String
  }

}
