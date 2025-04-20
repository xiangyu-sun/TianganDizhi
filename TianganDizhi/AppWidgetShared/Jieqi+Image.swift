import ChineseAstrologyCalendar
#if canImport(UIKit)
import UIKit
extension Jieqi {
  var image: UIImage {
    UIImage(named: "\(stringValue)") ?? UIImage()
  }
}
#endif

#if canImport(AppKit)
import AppKit

extension Jieqi {
  var image: NSImage {
    NSImage(imageLiteralResourceName: "\(stringValue)")
  }
}
#endif


