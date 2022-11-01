import Foundation
import ChineseAstrologyCalendar

struct MinuteTimeLineScheduler {
    static func buildTimeLine() -> [Date]{
        
        var timeline = [Date]()
        let currentDate = Date()
    
        timeline.append(currentDate)
        
        for minuteOffset in 0 ... 60 * 12 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            timeline.append(entryDate)
        }
        return timeline
    }
}
