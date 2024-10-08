import ChineseAstrologyCalendar
import Foundation

struct MinuteTimeLineScheduler {
  static func buildTimeLine() -> [Date] {
    var timeline = [Date]()
    let currentDate = Date()

    for minuteOffset in 0 ... 6 * 12 {
      let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset * 5 , to: currentDate) ?? Date()
      timeline.append(entryDate)
    }
    return timeline
  }
}
