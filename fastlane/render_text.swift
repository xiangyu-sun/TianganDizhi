// Renders text to transparent PNGs with macOS text layout (CoreText via AppKit).
// Use this instead of Pillow for any store text: it shapes Arabic and Devanagari,
// picks the right CJK glyphs per language and lays out right-to-left text correctly.
//
// Usage: swift render_text.swift jobs.json
// jobs.json: [{"text", "lang", "size", "width", "maxLines", "out",
//              "align"?: "left"|"center"|"right"|"natural" (default center),
//              "weight"?: "regular"|"medium"|"semibold"|"bold"|"heavy"|"black" (default heavy),
//              "color"?: "#RRGGBB" or "#RRGGBBAA" (default white),
//              "lineHeight"?: Double (default 1.05)}]
// Each job shrinks until it fits `width` in at most `maxLines` lines without breaking a word.
// Text with explicit "\n" breaks keeps exactly those lines (maxLines is ignored).
// The PNG is exactly `width` wide; read its height back to lay out the next block.

import AppKit

struct Job: Decodable {
  let text: String
  let lang: String
  let size: Double
  let width: Double
  let maxLines: Int
  let out: String
  var align: String?
  var weight: String?
  var color: String?
  var lineHeight: Double?
}

func nsColor(_ hex: String?) -> NSColor {
  guard var s = hex?.trimmingCharacters(in: .whitespaces), s.hasPrefix("#") else { return .white }
  s.removeFirst()
  guard let v = UInt64(s, radix: 16) else { return .white }
  let hasAlpha = s.count == 8
  let r = CGFloat((v >> (hasAlpha ? 24 : 16)) & 0xFF) / 255
  let g = CGFloat((v >> (hasAlpha ? 16 : 8)) & 0xFF) / 255
  let b = CGFloat((v >> (hasAlpha ? 8 : 0)) & 0xFF) / 255
  let a = hasAlpha ? CGFloat(v & 0xFF) / 255 : 1
  return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
}

func fontWeight(_ name: String?) -> NSFont.Weight {
  switch name {
  case "regular": return .regular
  case "medium": return .medium
  case "semibold": return .semibold
  case "bold": return .bold
  case "black": return .black
  default: return .heavy
  }
}

func alignment(_ name: String?) -> NSTextAlignment {
  switch name {
  case "left": return .left
  case "right": return .right
  case "natural": return .natural
  default: return .center
  }
}

func attributed(_ job: Job, size: CGFloat) -> NSAttributedString {
  let paragraph = NSMutableParagraphStyle()
  paragraph.alignment = alignment(job.align)
  paragraph.lineBreakMode = .byWordWrapping
  paragraph.lineHeightMultiple = CGFloat(job.lineHeight ?? 1.05)
  if job.lang.hasPrefix("ar") || job.lang.hasPrefix("he") { paragraph.baseWritingDirection = .rightToLeft }
  return NSAttributedString(string: job.text, attributes: [
    .font: NSFont.systemFont(ofSize: size, weight: fontWeight(job.weight)),
    .foregroundColor: nsColor(job.color),
    .paragraphStyle: paragraph,
    NSAttributedString.Key(kCTLanguageAttributeName as String): job.lang,
  ])
}

func lineCount(_ text: NSAttributedString, width: CGFloat) -> Int {
  let storage = NSTextStorage(attributedString: text)
  let layout = NSLayoutManager()
  let container = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
  container.lineFragmentPadding = 0
  layout.addTextContainer(container)
  storage.addLayoutManager(layout)
  var lines = 0
  var index = 0
  while index < layout.numberOfGlyphs {
    var range = NSRange()
    layout.lineFragmentRect(forGlyphAt: index, effectiveRange: &range)
    index = NSMaxRange(range)
    lines += 1
  }
  return lines
}

/// True when a single word is wider than the line and would be broken mid-word.
/// Chinese, Japanese and Thai don't separate words with spaces and may break between
/// any characters, so the whole sentence would count as one "word": skip them.
func breaksWords(_ text: NSAttributedString, width: CGFloat, lang: String) -> Bool {
  if ["zh", "ja", "th"].contains(where: lang.hasPrefix) { return false }
  return text.string.split(whereSeparator: \.isWhitespace).contains { word in
    let single = NSMutableAttributedString(attributedString: text)
    single.mutableString.setString(String(word))
    return single.boundingRect(with: CGSize(width: 100_000, height: 100_000), options: .usesLineFragmentOrigin).width > width
  }
}

let data = try Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))
for job in try JSONDecoder().decode([Job].self, from: data) {
  let width = CGFloat(job.width)
  var size = CGFloat(job.size)
  var text = attributed(job, size: size)
  // Hand-broken text ("line one\nline two") keeps exactly those lines: shrink, never re-wrap.
  let hardLines = job.text.split(separator: "\n", omittingEmptySubsequences: false).count
  let maxLines = hardLines > 1 ? hardLines : job.maxLines
  while size > 12, lineCount(text, width: width) > maxLines || breaksWords(text, width: width, lang: job.lang) {
    size *= 0.96
    text = attributed(job, size: size)
  }
  let bounds = text.boundingRect(
    with: CGSize(width: width, height: .greatestFiniteMagnitude),
    options: [.usesLineFragmentOrigin, .usesFontLeading])
  let height = max(1, Int(ceil(bounds.height)))
  guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: Int(width), pixelsHigh: height,
    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
    colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)
  else { fatalError("bitmap") }
  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
  text.draw(with: CGRect(x: 0, y: 0, width: width, height: CGFloat(height)),
            options: [.usesLineFragmentOrigin, .usesFontLeading])
  NSGraphicsContext.restoreGraphicsState()
  try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: job.out))
}
