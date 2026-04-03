import ChineseAstrologyCalendar
#if canImport(UIKit)
import UIKit
extension Jieqi {
  var image: UIImage {
    UIImage(named: imageName) ?? UIImage()
  }
}
#endif

#if canImport(AppKit)
import AppKit

extension Jieqi {
  var image: NSImage {
    NSImage(imageLiteralResourceName: imageName)
  }
}
#endif

extension Jieqi {
  // Maps Jieqi cases to the pinyin asset names used in the image catalog
  var imageName: String {
    switch self {
    case .springEquinox: return "chunfen"
    case .clearAndBright: return "qingming"
    case .grainRain: return "guyu"
    case .startOfSummer: return "lixia"
    case .grainBuds: return "xiaoman"
    case .grainInEar: return "mangzhong"
    case .summerSolstice: return "xiazhi"
    case .minorHeat: return "xiaoshu"
    case .majorHeat: return "dashu"
    case .startOfAutumn: return "liqiu"
    case .endOfHeat: return "chushu"
    case .whiteDew: return "bailu"
    case .autumnEquinox: return "qiufen"
    case .coldDew: return "hanlu"
    case .frostDescent: return "shuangjiang"
    case .startOfWinter: return "lidong"
    case .minorSnow: return "xiaoxue"
    case .majorSnow: return "daxue"
    case .winterSolstice: return "dongzhi"
    case .minorCold: return "xiaohan"
    case .majorCold: return "dahan"
    case .startOfSpring: return "lichun"
    case .rainWater: return "yushui"
    case .awakeningOfInsects: return "jingzhe"
    }
  }
}
