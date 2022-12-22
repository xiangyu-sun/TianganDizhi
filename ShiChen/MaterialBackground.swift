//
//  MaterialBackground.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 22/12/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI

struct MaterialBackground: ViewModifier {
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled: Bool = false
  var image: Image
  var toogle: Bool
  
  func body(content: Content) -> some View {
    if !springFestiveBackgroundEnabled {
      content
        .background(image.resizable(resizingMode: .tile).ignoresSafeArea(.all))
      
    } else {
      content
        .background(
          image
            .resizable(resizingMode: .tile)
            .renderingMode(.template)
            .ignoresSafeArea(.all)
            .foregroundColor(Color("sprintfestivaltint"))
        )
    }
    
  }
}

extension View {
  func materialBackground(with image:Image, toogle: Bool) -> some View {
    modifier(MaterialBackground(image: image, toogle: toogle))
  }
}
