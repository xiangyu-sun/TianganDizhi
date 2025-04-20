import ChineseAstrologyCalendar
import UIKit

extension Jieqi {
  var image: UIImage {
    UIImage(named: "\(stringValue)") ?? UIImage()
  }
}
