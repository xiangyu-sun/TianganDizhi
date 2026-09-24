import ChineseAstrologyCalendar
import Foundation

/// Quarter-hourly widget timeline: "now", then every 刻 boundary (:00, :15, :30,
/// :45) for the next 12 hours. The name predates the 15-minute step.
///
/// Entries sit on the boundaries rather than at `now + 15·k`: offsets from `now`
/// (12:07, 12:22, …) showed a 時辰 or 刻 change up to 15 minutes late. The grid
/// is computed arithmetically, so there is no failable date step whose
/// `?? Date()` fallback could insert an out-of-order entry and break WidgetKit's
/// strictly-increasing requirement (see `ShichenTimeLineSceduler`). Quarter hours
/// since the reference date are local quarter hours in every real time zone, as
/// all UTC offsets are multiples of 15 minutes.
enum MinuteTimeLineScheduler {
  static let step: TimeInterval = 15 * 60
  static let boundaryCount = 48

  static func buildTimeLine(now: Date = Date()) -> [Date] {
    let firstBoundary = (now.timeIntervalSinceReferenceDate / step).rounded(.down) * step + step
    return [now] + (0 ..< boundaryCount).map {
      Date(timeIntervalSinceReferenceDate: firstBoundary + Double($0) * step)
    }
  }
}
