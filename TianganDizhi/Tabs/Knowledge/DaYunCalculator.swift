import ChineseAstrologyCalendar
import Foundation

// MARK: - DaYun

struct DaYun: Identifiable {
  let id = UUID()
  let tiangan: Tiangan
  let dizhi: Dizhi
  let startAge: Int
  let endAge: Int
}

// MARK: - DaYunCalculator

struct DaYunCalculator {

  // Returns DaYun start age and 8 cycles for the given birth date and gender.
  // Returns nil if Bazi cannot be computed.
  static func calculate(birthDate: Date, isMale: Bool) -> (startAge: Int, cycles: [DaYun])? {
    guard let bazi = Bazi(date: birthDate) else { return nil }

    // allCharacters: [nianGan, nianZhi, yueGan, yueZhi, riGan, riZhi, shiGan, shiZhi]
    let chars = bazi.allCharacters
    guard chars.count >= 4 else { return nil }

    // Find year stem to determine yin/yang.
    guard let yearStem = Tiangan.allCases.first(where: { $0.chineseCharacter == chars[0] }) else { return nil }

    // 順 (forward): yang year + male, or yin year + female.
    let isForward = isMale ? !yearStem.yin : yearStem.yin

    // Days between birth and the relevant solar term. 起運 age is measured
    // against the 12 節 (month-boundary terms), not all 24 節氣 — using every
    // term here would roughly halve the interval and understate startAge.
    let days: Int
    if isForward {
      days = daysToNextJie(from: birthDate)
    } else {
      days = daysSincePreviousJie(from: birthDate)
    }

    let startAge = Int(ceil(Double(days) / 3.0))

    // Find month pillar Tiangan and Dizhi by character matching.
    guard
      let monthTiangan = Tiangan.allCases.first(where: { $0.chineseCharacter == chars[2] }),
      let monthDizhi = Dizhi.allCases.first(where: { $0.chineseCharacter == chars[3] })
    else { return nil }

    let step = isForward ? 1 : -1
    let tianganAll = Tiangan.allCases
    let dizhiAll = Dizhi.allCases
    var tIndex = tianganAll.firstIndex(of: monthTiangan) ?? 0
    var dIndex = dizhiAll.firstIndex(of: monthDizhi) ?? 0

    var cycles: [DaYun] = []
    for i in 0..<8 {
      tIndex = ((tIndex + step) % 10 + 10) % 10
      dIndex = ((dIndex + step) % 12 + 12) % 12
      let age = startAge + i * 10
      cycles.append(DaYun(
        tiangan: tianganAll[tIndex],
        dizhi: dizhiAll[dIndex],
        startAge: age,
        endAge: age + 9
      ))
    }

    return (startAge, cycles)
  }

  // Days forward from `date` to the start of the next 節 (jie) — walks in
  // calendar days (not a fixed 86400s) so it doesn't drift across a DST
  // transition, and filters to jie starts specifically rather than any of
  // the 24 節氣 the package's plain `nextJieqi` would stop at.
  //
  // Pinned to GMT+8, matching `Bazi(date:)`'s own convention: `birthDate` is
  // always meant to be read as a GMT+8 wall clock, so the day boundaries used
  // to count 節 distance must be GMT+8's, not the calculating device's
  // ambient timezone — otherwise the same birth instant yields a different
  // (and possibly wrong) day count depending on where the app happens to run.
  private static func daysToNextJie(from date: Date) -> Int {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 8 * 3600)!
    var probe = date
    for offset in 1...400 {
      guard let next = calendar.date(byAdding: .day, value: 1, to: probe) else { break }
      if next.isJieqiDay, let jieqi = next.jieqi, !jieqi.qi {
        return offset
      }
      probe = next
    }
    return 0
  }

  // Days elapsed since the most recent 節 (jie) began, up to and including
  // `date`. Symmetric with `daysToNextJie`: same calendar-day stepping, same
  // jie-only filter — the original walked backward in exact-instant jumps
  // and stopped at any jieqi change (jie or qi), which is a different, and
  // roughly half as large, quantity than the forward branch measured.
  private static func daysSincePreviousJie(from date: Date) -> Int {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 8 * 3600)!
    var probe = date
    for offset in 1...400 {
      guard let previous = calendar.date(byAdding: .day, value: -1, to: probe) else { break }
      if previous.isJieqiDay, let jieqi = previous.jieqi, !jieqi.qi {
        return offset
      }
      probe = previous
    }
    return 0
  }
}
