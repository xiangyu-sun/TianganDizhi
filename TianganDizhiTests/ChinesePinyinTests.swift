//
//  ChinesePinyinTests.swift
//  TianganDizhiTests
//
//  Tests for the app-specific String.transformToPinyin() extension.
//

import Testing
@testable import TianganDizhi

struct ChinesePinyinTests {

    // Helper to strip tone marks for comparison
    private func stripToneMarks(_ string: String) -> String {
        let toneMap: [Character: Character] = [
            "ā": "a", "á": "a", "ǎ": "a", "à": "a",
            "ē": "e", "é": "e", "ě": "e", "è": "e",
            "ī": "i", "í": "i", "ǐ": "i", "ì": "i",
            "ō": "o", "ó": "o", "ǒ": "o", "ò": "o",
            "ū": "u", "ú": "u", "ǔ": "u", "ù": "u",
            "ǖ": "v", "ǘ": "v", "ǚ": "v", "ǜ": "v", "ü": "v"
        ]
        return String(string.map { toneMap[$0] ?? $0 })
    }

    // MARK: - Single Character Tests

    @Test("Single Chinese character 子 converts to pinyin containing zi")
    func singleCharacterZi() {
        let result = "子".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("zi"))
    }

    @Test("Single Chinese character 甲 converts to pinyin containing jia")
    func singleCharacterJia() {
        let result = "甲".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("jia"))
    }

    @Test("Single Chinese character 龍 converts to pinyin containing long")
    func singleCharacterLong() {
        let result = "龍".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("long"))
    }

    // MARK: - Multiple Character Tests

    @Test("Multiple Chinese characters 天干 converts to pinyin")
    func multipleCharactersTiangan() {
        let result = "天干".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("tian"))
        #expect(stripped.contains("gan"))
    }

    @Test("Multiple Chinese characters 地支 converts to pinyin")
    func multipleCharactersDizhi() {
        let result = "地支".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        // Note: 地 can be "di" or "de" depending on context
        #expect(stripped.contains("de") || stripped.contains("di"))
        #expect(stripped.contains("zhi"))
    }

    // MARK: - Edge Cases

    @Test("Empty string returns empty string")
    func emptyString() {
        let result = "".transformToPinyin()
        #expect(result.isEmpty)
    }

    @Test("English text remains unchanged or minimally changed")
    func englishText() {
        let input = "Hello"
        let result = input.transformToPinyin()
        #expect(result.lowercased().contains("hello"))
    }

    @Test("Mixed Chinese and English text")
    func mixedChineseEnglish() {
        let result = "天干Tiangan".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("tian"))
        #expect(stripped.contains("gan"))
        #expect(stripped.contains("tiangan"))
    }

    @Test("Numbers remain unchanged")
    func numbersUnchanged() {
        let input = "123456"
        let result = input.transformToPinyin()
        #expect(result == input)
    }

    @Test("Special characters handling")
    func specialCharacters() {
        let input = "!@#$%^&*()"
        let result = input.transformToPinyin()
        // Special characters should be preserved
        #expect(!result.isEmpty)
    }

    // MARK: - Tiangan Characters

    @Test("Tiangan character 甲 converts correctly")
    func tianganJia() {
        let result = "甲".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("jia"))
    }

    @Test("Tiangan character 乙 converts correctly")
    func tianganYi() {
        let result = "乙".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("yi"))
    }

    @Test("Tiangan character 丙 converts correctly")
    func tianganBing() {
        let result = "丙".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("bing"))
    }

    // MARK: - Dizhi Characters

    @Test("Dizhi character 子 converts correctly")
    func dizhiZi() {
        let result = "子".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("zi"))
    }

    @Test("Dizhi character 丑 converts correctly")
    func dizhiChou() {
        let result = "丑".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("chou"))
    }

    @Test("Dizhi character 寅 converts correctly")
    func dizhiYin() {
        let result = "寅".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("yin"))
    }

    // MARK: - Complex Phrases

    @Test("Complex phrase 天干地支 converts correctly")
    func complexPhrase() {
        let result = "天干地支".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("tian"))
        #expect(stripped.contains("gan"))
        // Note: 地 can be "di" or "de" depending on context
        #expect(stripped.contains("de") || stripped.contains("di"))
        #expect(stripped.contains("zhi"))
    }

    @Test("Chinese text with spaces converts correctly")
    func chineseTextWithSpaces() {
        let result = "天干 地支".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("tian"))
        #expect(stripped.contains("zhi"))
    }

    @Test("Traditional character 龍 converts correctly")
    func traditionalCharacter() {
        let result = "龍".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("long"))
    }

    @Test("Simplified character 龙 converts correctly")
    func simplifiedCharacter() {
        let result = "龙".transformToPinyin()
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("long"))
    }

    // MARK: - Output Format Tests

    @Test("Pinyin output is not empty for Chinese input")
    func pinyinOutputNotEmpty() {
        let inputs = ["中", "文", "字", "体"]
        for input in inputs {
            let result = input.transformToPinyin()
            #expect(!result.isEmpty, "Pinyin for '\(input)' should not be empty")
        }
    }

    @Test("Pinyin output preserves word structure")
    func pinyinPreservesStructure() {
        let result = "你好".transformToPinyin()
        // Should contain some form of "ni" and "hao"
        let stripped = stripToneMarks(result.lowercased())
        #expect(stripped.contains("ni"))
        #expect(stripped.contains("hao"))
    }
}
