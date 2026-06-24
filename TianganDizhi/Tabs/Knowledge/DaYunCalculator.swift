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

    // Days between birth and the relevant solar term.
    let days: Int
    if isForward {
      days = birthDate.nextJieqi.map { $0.days(from: birthDate) } ?? 0
    } else {
      days = daysSincePreviousJieqi(from: birthDate)
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

  // Days elapsed since the last solar term transition before `date`.
  private static func daysSincePreviousJieqi(from date: Date) -> Int {
    let currentJieqi = date.jieqi
    var days = 0
    for offset in 1...20 {
      let checkDate = date.addingTimeInterval(TimeInterval(-offset) * 86400)
      if checkDate.jieqi != currentJieqi {
        break
      }
      days = offset
    }
    return days
  }
}
