import Foundation

struct AIMLAssetManifest {
    static let aimlFiles = [
        "bot_profile", "date", "dialog", "familiar", "help", "inquiry", "insults", "ontology", "picture", "that", "udc", "update"
    ]
    static let configFiles = ["normal", "denormal", "gender", "person", "person2", "predicates", "properties"]
}

struct AIMLBundleCategory {
    let pattern: String
    let templateText: String
}

final class AIMLAssetLoader {
    func loadCategories(bundle: Bundle = .main) -> [AIMLBundleCategory] {
        return AIMLAssetManifest.aimlFiles.flatMap { name -> [AIMLBundleCategory] in
            guard let url = bundle.url(forResource: name, withExtension: "aiml", subdirectory: "Hari/aiml"),
                  let text = try? String(contentsOf: url, encoding: .utf8) else { return [] }
            return parseCategories(text)
        }
    }

    func loadSubstitution(named name: String, bundle: Bundle = .main) -> AIMLSubstitutionTable {
        guard let url = bundle.url(forResource: name, withExtension: "txt", subdirectory: "Hari/config"),
              let text = try? String(contentsOf: url, encoding: .utf8) else { return .empty }
        return AIMLSubstitutionTable.parse(text)
    }

    func loadPredicates(bundle: Bundle = .main) -> [String: String] {
        guard let url = bundle.url(forResource: "predicates", withExtension: "txt", subdirectory: "Hari/config"),
              let text = try? String(contentsOf: url, encoding: .utf8) else { return [:] }
        var values: [String: String] = [:]
        for raw in text.split(whereSeparator: \.isNewline) {
            let line = String(raw).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, !line.hasPrefix("#"), let idx = line.firstIndex(of: ":") else { continue }
            let key = String(line[..<idx]).trimmingCharacters(in: .whitespaces).lowercased()
            let value = String(line[line.index(after: idx)...]).trimmingCharacters(in: .whitespaces)
            values[key] = value
        }
        return values
    }

    func loadProperties(bundle: Bundle = .main) -> [String: String] {
        guard let url = bundle.url(forResource: "properties", withExtension: "txt", subdirectory: "Hari/config"),
              let text = try? String(contentsOf: url, encoding: .utf8) else { return [:] }
        var values: [String: String] = [:]
        for raw in text.split(whereSeparator: \.isNewline) {
            let line = String(raw).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, let idx = line.firstIndex(of: ":") else { continue }
            values[String(line[..<idx]).lowercased()] = String(line[line.index(after: idx)...])
        }
        return values
    }

    private func parseCategories(_ xml: String) -> [AIMLBundleCategory] {
        var result: [AIMLBundleCategory] = []
        let categoryPattern = #"(?is)<category>(.*?)</category>"#
        let patternPattern = #"(?is)<pattern>(.*?)</pattern>"#
        let templatePattern = #"(?is)<template>(.*?)</template>"#
        guard let categoryRegex = try? NSRegularExpression(pattern: categoryPattern),
              let patternRegex = try? NSRegularExpression(pattern: patternPattern),
              let templateRegex = try? NSRegularExpression(pattern: templatePattern) else { return [] }
        let full = NSRange(xml.startIndex..<xml.endIndex, in: xml)
        for match in categoryRegex.matches(in: xml, range: full) {
            guard let bodyRange = Range(match.range(at: 1), in: xml) else { continue }
            let body = String(xml[bodyRange])
            let bodyNS = NSRange(body.startIndex..<body.endIndex, in: body)
            guard let p = patternRegex.firstMatch(in: body, range: bodyNS),
                  let t = templateRegex.firstMatch(in: body, range: bodyNS),
                  let pr = Range(p.range(at: 1), in: body), let tr = Range(t.range(at: 1), in: body) else { continue }
            let pattern = cleanXML(String(body[pr])).uppercased()
            let template = cleanXML(String(body[tr]))
            if !pattern.isEmpty && !template.isEmpty { result.append(.init(pattern: pattern, templateText: template)) }
        }
        return result
    }

    private func cleanXML(_ value: String) -> String {
        value
            .replacingOccurrences(of: #"<[^>]+>"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .split(whereSeparator: \.isWhitespace).joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

final class BundledAIMLChatEngine {
    private let categories: [AIMLBundleCategory]
    private let normalizer: AIMLSubstitutionTable
    private let fallback = SwiftAIMLChatEngine()

    init(bundle: Bundle = .main) {
        let loader = AIMLAssetLoader()
        categories = loader.loadCategories(bundle: bundle)
        normalizer = loader.loadSubstitution(named: "normal", bundle: bundle)
    }

    var loadedCategoryCount: Int { categories.count }

    func reply(to input: String) -> String {
        let normalized = normalizer.apply(input).uppercased()
        for category in categories {
            if let match = AIMLPatternMatcher.match(pattern: category.pattern, input: normalized) {
                var text = category.templateText
                for (index, star) in match.stars.enumerated() {
                    text = text.replacingOccurrences(of: "<star index=\"\(index + 1)\"/>", with: star)
                }
                return text
            }
        }
        return fallback.reply(to: input)
    }
}
