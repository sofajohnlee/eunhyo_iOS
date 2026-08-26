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
            values[String(line[..<idx]).trimmingCharacters(in: .whitespaces).lowercased()] = String(line[line.index(after: idx)...]).trimmingCharacters(in: .whitespaces)
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
            let pattern = cleanText(String(body[pr])).uppercased()
            let template = String(body[tr]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !pattern.isEmpty && !template.isEmpty { result.append(.init(pattern: pattern, templateText: template)) }
        }
        return result
    }

    private func cleanText(_ value: String) -> String {
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
    private let predicates: AIMLPredicateStore
    private let properties: [String: String]
    private let fallback = SwiftAIMLChatEngine()
    private var requestHistory: [String] = []
    private var responseHistory: [String] = []

    init(bundle: Bundle = .main) {
        let loader = AIMLAssetLoader()
        categories = loader.loadCategories(bundle: bundle)
        normalizer = loader.loadSubstitution(named: "normal", bundle: bundle)
        predicates = AIMLPredicateStore(values: loader.loadPredicates(bundle: bundle))
        properties = loader.loadProperties(bundle: bundle)
    }

    var loadedCategoryCount: Int { categories.count }

    func reply(to input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "질문을 입력해 주세요." }
        requestHistory.insert(trimmed, at: 0)
        if requestHistory.count > 32 { requestHistory.removeLast() }
        let answer = replyInternal(to: trimmed, depth: 0) ?? fallback.reply(to: trimmed)
        responseHistory.insert(answer, at: 0)
        if responseHistory.count > 32 { responseHistory.removeLast() }
        return answer
    }

    private func replyInternal(to input: String, depth: Int) -> String? {
        guard depth < 12 else { return nil }
        let normalized = normalizer.apply(input).uppercased()
        for category in categories {
            if let match = AIMLPatternMatcher.match(pattern: category.pattern, input: normalized) {
                let rendered = render(category.templateText, stars: match.stars, depth: depth)
                if !rendered.isEmpty { return rendered }
            }
        }
        return nil
    }

    private func render(_ template: String, stars: [String], depth: Int) -> String {
        var text = template

        text = replacePairedTag(in: text, tag: "think") { body, _ in
            _ = self.render(body, stars: stars, depth: depth + 1)
            return ""
        }

        text = replacePairedTag(in: text, tag: "random") { body, _ in
            let items = self.pairedTagBodies(in: body, tag: "li")
            guard let choice = items.randomElement() else { return "" }
            return self.render(choice.body, stars: stars, depth: depth + 1)
        }

        text = replacePairedTag(in: text, tag: "condition") { body, attrs in
            self.renderCondition(body: body, attributes: attrs, stars: stars, depth: depth + 1)
        }

        text = replacePairedTag(in: text, tag: "set") { body, attrs in
            guard let name = self.attribute("name", in: attrs) else { return self.render(body, stars: stars, depth: depth + 1) }
            let value = self.render(body, stars: stars, depth: depth + 1)
            return self.predicates.set(name, value)
        }

        text = replacePairedTag(in: text, tag: "srai") { body, _ in
            let redirected = self.render(body, stars: stars, depth: depth + 1)
            return self.replyInternal(to: redirected, depth: depth + 1) ?? ""
        }

        text = replaceSelfClosingTag(in: text, tag: "star") { attrs in
            let index = Int(self.attribute("index", in: attrs) ?? "1") ?? 1
            guard index > 0, index <= stars.count else { return "" }
            return stars[index - 1]
        }

        text = replaceSelfClosingTag(in: text, tag: "get") { attrs in
            guard let name = self.attribute("name", in: attrs) else { return "" }
            return self.predicates.get(name)
        }

        text = replaceSelfClosingTag(in: text, tag: "bot") { attrs in
            guard let name = self.attribute("name", in: attrs) else { return "" }
            return self.properties[name.lowercased()] ?? ""
        }

        text = replaceSelfClosingTag(in: text, tag: "request") { attrs in
            let index = Int(self.attribute("index", in: attrs) ?? "1") ?? 1
            guard index > 0, index <= self.requestHistory.count else { return "" }
            return self.requestHistory[index - 1]
        }

        text = replaceSelfClosingTag(in: text, tag: "response") { attrs in
            let index = Int(self.attribute("index", in: attrs) ?? "1") ?? 1
            guard index > 0, index <= self.responseHistory.count else { return "" }
            return self.responseHistory[index - 1]
        }

        text = replaceSelfClosingTag(in: text, tag: "date") { _ in
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: Date())
        }

        text = text.replacingOccurrences(of: #"(?is)<oob>.*?</oob>"#, with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: #"(?is)<[^>]+>"#, with: " ", options: .regularExpression)
        return cleanOutput(text)
    }

    private func renderCondition(body: String, attributes: String, stars: [String], depth: Int) -> String {
        guard let name = attribute("name", in: attributes) else { return "" }
        let current = predicates.get(name)
        let items = pairedTagBodies(in: body, tag: "li")
        var defaultBody: String?
        for item in items {
            if let value = attribute("value", in: item.attributes) {
                if value.caseInsensitiveCompare(current) == .orderedSame {
                    return render(item.body, stars: stars, depth: depth)
                }
            } else if defaultBody == nil {
                defaultBody = item.body
            }
        }
        return defaultBody.map { render($0, stars: stars, depth: depth) } ?? ""
    }

    private func replacePairedTag(in source: String, tag: String, transform: (String, String) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "(?is)<\\s*\(tag)\\b([^>]*)>(.*?)<\\s*/\\s*\(tag)\\s*>") else { return source }
        var result = source
        while true {
            let range = NSRange(result.startIndex..<result.endIndex, in: result)
            guard let match = regex.firstMatch(in: result, range: range),
                  let whole = Range(match.range(at: 0), in: result),
                  let attrs = Range(match.range(at: 1), in: result),
                  let body = Range(match.range(at: 2), in: result) else { break }
            let replacement = transform(String(result[body]), String(result[attrs]))
            result.replaceSubrange(whole, with: replacement)
        }
        return result
    }

    private func replaceSelfClosingTag(in source: String, tag: String, transform: (String) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "(?is)<\\s*\(tag)\\b([^>]*)/\\s*>") else { return source }
        var result = source
        while true {
            let range = NSRange(result.startIndex..<result.endIndex, in: result)
            guard let match = regex.firstMatch(in: result, range: range),
                  let whole = Range(match.range(at: 0), in: result),
                  let attrs = Range(match.range(at: 1), in: result) else { break }
            result.replaceSubrange(whole, with: transform(String(result[attrs])))
        }
        return result
    }

    private func pairedTagBodies(in source: String, tag: String) -> [(body: String, attributes: String)] {
        guard let regex = try? NSRegularExpression(pattern: "(?is)<\\s*\(tag)\\b([^>]*)>(.*?)<\\s*/\\s*\(tag)\\s*>") else { return [] }
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        return regex.matches(in: source, range: range).compactMap { match in
            guard let attrs = Range(match.range(at: 1), in: source),
                  let body = Range(match.range(at: 2), in: source) else { return nil }
            return (String(source[body]), String(source[attrs]))
        }
    }

    private func attribute(_ name: String, in attributes: String) -> String? {
        let escaped = NSRegularExpression.escapedPattern(for: name)
        guard let regex = try? NSRegularExpression(pattern: "(?i)\\b\(escaped)\\s*=\\s*[\\\"']([^\\\"']*)[\\\"']") else { return nil }
        let range = NSRange(attributes.startIndex..<attributes.endIndex, in: attributes)
        guard let match = regex.firstMatch(in: attributes, range: range),
              let valueRange = Range(match.range(at: 1), in: attributes) else { return nil }
        return String(attributes[valueRange])
    }

    private func cleanOutput(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
