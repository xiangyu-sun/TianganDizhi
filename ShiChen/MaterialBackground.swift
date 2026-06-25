//
//  MaterialBackground.swift
//  TianganDizhi
//
//  Created by Xiangyu Sun on 22/12/22.
//  Copyright © 2022 孙翔宇. All rights reserved.
//

import SwiftUI

// MARK: - MaterialBackground

struct MaterialBackground: ViewModifier {
  @AppStorage(Constants.springFestiveBackgroundEnabled, store: Constants.sharedUserDefault)
  var springFestiveBackgroundEnabled = false

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
            .foregroundStyle(Color("sprintfestivaltint")))
    }
  }
}

// MARK: - iOS 17+ widget backgrounds

@available(iOS 17.0, macOS 14.0, *)
private struct MarbleWidgetBackground: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  @AppStorage(Constants.backgroundStyle, store: Constants.sharedUserDefault)
  var backgroundStyle = 0

  func body(content: Content) -> some View {
    content.containerBackground(for: .widget) {
      GeometryReader { geo in
        let isDark: Float = colorScheme == .dark ? 1.0 : 0.0
        Rectangle()
          .colorEffect(
            backgroundStyle == 1
              ? ShaderLibrary.stoneMarble(.float2(geo.size.width, geo.size.height), .float(isDark))
              : ShaderLibrary.marble(.float2(geo.size.width, geo.size.height), .float(isDark))
          )
      }
    }
  }
}

@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
private struct FestiveWidgetBackground: ViewModifier {
  var image: Image

  func body(content: Content) -> some View {
    content.containerBackground(for: .widget) {
      image
        .resizable(resizingMode: .tile)
        .renderingMode(.template)
        .foregroundStyle(Color("sprintfestivaltint"))
    }
  }
}

// MARK: - View extensions

extension View {
  @ViewBuilder
  func materialBackgroundWidget(with image: Image, toogle: Bool) -> some View {
    if #available(iOS 17.0, watchOS 10.0, macOS 14.0, *) {
      if toogle {
        modifier(FestiveWidgetBackground(image: image))
      } else {
        modifier(MarbleWidgetBackground())
      }
    } else {
      modifier(MaterialBackground(image: image, toogle: toogle))
    }
  }

  func materialBackground(with image: Image, toogle: Bool) -> some View {
    modifier(MaterialBackground(image: image, toogle: toogle))
  }
}
