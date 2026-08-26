import Foundation

struct AIMLAssetManifest {
    static let aimlFiles = ["bot_profile", "date", "dialog", "familiar", "help", "inquiry", "insults", "ontology", "picture", "that", "udc", "update"]
    static let configFiles = ["normal", "denormal", "gender", "person", "person2", "predicates", "properties"]
}

struct AIMLBundleCategory {
    let pattern: String
    let thatPattern: String?
    let templateText: String
}

final class AIMLAssetLoader {
    func loadCategories(bundle: Bundle = .main) -> [AIMLBundleCategory] {
        AIMLAssetManifest.aimlFiles.flatMap { name -> [AIMLBundleCategory] in
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

    func loadPredicates(bundle: Bundle = .main) -> [String: String] { loadKeyValues(named: "predicates", bundle: bundle) }
    func loadProperties(bundle: Bundle = .main) -> [String: String] { loadKeyValues(named: "properties", bundle: bundle) }

    private func loadKeyValues(named name: String, bundle: Bundle) -> [String: String] {
        guard let url = bundle.url(forResource: name, withExtension: "txt", subdirectory: "Hari/config"),
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

    private func parseCategories(_ xml: String) -> [AIMLBundleCategory] {
        var result: [AIMLBundleCategory] = []
        guard let categoryRegex = try? NSRegularExpression(pattern: #"(?is)<category>(.*?)</category>"#),
              let patternRegex = try? NSRegularExpression(pattern: #"(?is)<pattern>(.*?)</pattern>"#),
              let thatRegex = try? NSRegularExpression(pattern: #"(?is)<that>(.*?)</that>"#),
              let templateRegex = try? NSRegularExpression(pattern: #"(?is)<template>(.*?)</template>"#) else { return [] }
        let full = NSRange(xml.startIndex..<xml.endIndex, in: xml)
        for match in categoryRegex.matches(in: xml, range: full) {
            guard let bodyRange = Range(match.range(at: 1), in: xml) else { continue }
            let body = String(xml[bodyRange]); let bodyNS = NSRange(body.startIndex..<body.endIndex, in: body)
            guard let p = patternRegex.firstMatch(in: body, range: bodyNS), let t = templateRegex.firstMatch(in: body, range: bodyNS),
                  let pr = Range(p.range(at: 1), in: body), let tr = Range(t.range(at: 1), in: body) else { continue }
            let pattern = cleanText(String(body[pr])).uppercased()
            var thatPattern: String? = nil
            if let tm = thatRegex.firstMatch(in: body, range: bodyNS), let rr = Range(tm.range(at: 1), in: body) {
                let cleaned = cleanText(String(body[rr])).uppercased(); if !cleaned.isEmpty { thatPattern = cleaned }
            }
            let template = String(body[tr]).trimmingCharacters(in: .whitespacesAndNewlines)
            if !pattern.isEmpty && !template.isEmpty { result.append(.init(pattern: pattern, thatPattern: thatPattern, templateText: template)) }
        }
        return result
    }

    private func cleanText(_ value: String) -> String {
        value.replacingOccurrences(of: #"<[^>]+>"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">")
            .split(whereSeparator: \.isWhitespace).joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
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
        requestHistory.insert(trimmed, at: 0); if requestHistory.count > 32 { requestHistory.removeLast() }
        let answer = replyInternal(to: trimmed, depth: 0) ?? fallback.reply(to: trimmed)
        responseHistory.insert(answer, at: 0); if responseHistory.count > 32 { responseHistory.removeLast() }
        return answer
    }

    private func replyInternal(to input: String, depth: Int) -> String? {
        guard depth < 12 else { return nil }
        let normalized = normalizer.apply(input).uppercased()
        let previous = responseHistory.first.map { normalizeThat($0) }
        for category in categories {
            guard let inputMatch = AIMLPatternMatcher.match(pattern: category.pattern, input: normalized) else { continue }
            var thatStars: [String] = []
            if let thatPattern = category.thatPattern {
                guard let previous, let thatMatch = AIMLPatternMatcher.match(pattern: thatPattern, input: previous) else { continue }
                thatStars = thatMatch.stars
            }
            let rendered = render(category.templateText, stars: inputMatch.stars, thatStars: thatStars, depth: depth)
            if !rendered.isEmpty { return rendered }
        }
        return nil
    }

    private func normalizeThat(_ text: String) -> String {
        normalizer.apply(text.replacingOccurrences(of: #"[.!?]+$"#, with: "", options: .regularExpression)).uppercased()
    }

    private func render(_ template: String, stars: [String], thatStars: [String], depth: Int) -> String {
        var text = template
        text = replacePairedTag(in: text, tag: "think") { body, _ in _ = self.render(body, stars: stars, thatStars: thatStars, depth: depth + 1); return "" }
        text = replacePairedTag(in: text, tag: "random") { body, _ in
            guard let choice = self.pairedTagBodies(in: body, tag: "li").randomElement() else { return "" }
            return self.render(choice.body, stars: stars, thatStars: thatStars, depth: depth + 1)
        }
        text = replacePairedTag(in: text, tag: "condition") { body, attrs in self.renderCondition(body: body, attributes: attrs, stars: stars, thatStars: thatStars, depth: depth + 1) }
        text = replacePairedTag(in: text, tag: "set") { body, attrs in
            let value = self.render(body, stars: stars, thatStars: thatStars, depth: depth + 1)
            guard let name = self.attribute("name", in: attrs) else { return value }
            return self.predicates.set(name, value)
        }
        text = replacePairedTag(in: text, tag: "srai") { body, _ in
            let redirected = self.render(body, stars: stars, thatStars: thatStars, depth: depth + 1)
            return self.replyInternal(to: redirected, depth: depth + 1) ?? ""
        }
        text = replaceSelfClosingTag(in: text, tag: "star") { attrs in self.indexedCapture(attrs: attrs, values: stars) }
        text = replaceSelfClosingTag(in: text, tag: "thatstar") { attrs in self.indexedCapture(attrs: attrs, values: thatStars) }
        text = replaceSelfClosingTag(in: text, tag: "get") { attrs in self.attribute("name", in: attrs).map(self.predicates.get) ?? "" }
        text = replaceSelfClosingTag(in: text, tag: "bot") { attrs in self.attribute("name", in: attrs).flatMap { self.properties[$0.lowercased()] } ?? "" }
        text = replaceSelfClosingTag(in: text, tag: "request") { attrs in self.historyValue(attrs: attrs, values: self.requestHistory) }
        text = replaceSelfClosingTag(in: text, tag: "response") { attrs in self.historyValue(attrs: attrs, values: self.responseHistory) }
        text = replaceSelfClosingTag(in: text, tag: "date") { _ in let f = DateFormatter(); f.locale = Locale.current; f.dateStyle = .medium; f.timeStyle = .short; return f.string(from: Date()) }
        text = text.replacingOccurrences(of: #"(?is)<oob>.*?</oob>"#, with: "", options: .regularExpression)
        text = text.replacingOccurrences(of: #"(?is)<[^>]+>"#, with: " ", options: .regularExpression)
        return cleanOutput(text)
    }

    private func indexedCapture(attrs: String, values: [String]) -> String {
        let index = Int(attribute("index", in: attrs) ?? "1") ?? 1
        guard index > 0, index <= values.count else { return "" }
        return values[index - 1]
    }

    private func historyValue(attrs: String, values: [String]) -> String {
        let index = Int(attribute("index", in: attrs) ?? "1") ?? 1
        guard index > 0, index <= values.count else { return "" }
        return values[index - 1]
    }

    private func renderCondition(body: String, attributes: String, stars: [String], thatStars: [String], depth: Int) -> String {
        guard let name = attribute("name", in: attributes) else { return "" }
        let current = predicates.get(name); let items = pairedTagBodies(in: body, tag: "li"); var defaultBody: String?
        for item in items {
            if let value = attribute("value", in: item.attributes), value.caseInsensitiveCompare(current) == .orderedSame {
                return render(item.body, stars: stars, thatStars: thatStars, depth: depth)
            } else if attribute("value", in: item.attributes) == nil && defaultBody == nil { defaultBody = item.body }
        }
        return defaultBody.map { render($0, stars: stars, thatStars: thatStars, depth: depth) } ?? ""
    }

    private func replacePairedTag(in source: String, tag: String, transform: (String, String) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "(?is)<\\s*\(tag)\\b([^>]*)>(.*?)<\\s*/\\s*\(tag)\\s*>") else { return source }
        var result = source
        while true {
            let range = NSRange(result.startIndex..<result.endIndex, in: result)
            guard let match = regex.firstMatch(in: result, range: range), let whole = Range(match.range(at: 0), in: result), let attrs = Range(match.range(at: 1), in: result), let body = Range(match.range(at: 2), in: result) else { break }
            result.replaceSubrange(whole, with: transform(String(result[body]), String(result[attrs])))
        }
        return result
    }

    private func replaceSelfClosingTag(in source: String, tag: String, transform: (String) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: "(?is)<\\s*\(tag)\\b([^>]*)/\\s*>") else { return source }
        var result = source
        while true {
            let range = NSRange(result.startIndex..<result.endIndex, in: result)
            guard let match = regex.firstMatch(in: result, range: range), let whole = Range(match.range(at: 0), in: result), let attrs = Range(match.range(at: 1), in: result) else { break }
            result.replaceSubrange(whole, with: transform(String(result[attrs])))
        }
        return result
    }

    private func pairedTagBodies(in source: String, tag: String) -> [(body: String, attributes: String)] {
        guard let regex = try? NSRegularExpression(pattern: "(?is)<\\s*\(tag)\\b([^>]*)>(.*?)<\\s*/\\s*\(tag)\\s*>") else { return [] }
        let range = NSRange(source.startIndex..<source.endIndex, in: source)
        return regex.matches(in: source, range: range).compactMap { match in
            guard let attrs = Range(match.range(at: 1), in: source), let body = Range(match.range(at: 2), in: source) else { return nil }
            return (String(source[body]), String(source[attrs]))
        }
    }

    private func attribute(_ name: String, in attributes: String) -> String? {
        let escaped = NSRegularExpression.escapedPattern(for: name)
        guard let regex = try? NSRegularExpression(pattern: "(?i)\\b\(escaped)\\s*=\\s*[\\\"']([^\\\"']*)[\\\"']") else { return nil }
        let range = NSRange(attributes.startIndex..<attributes.endIndex, in: attributes)
        guard let match = regex.firstMatch(in: attributes, range: range), let valueRange = Range(match.range(at: 1), in: attributes) else { return nil }
        return String(attributes[valueRange])
    }

    private func cleanOutput(_ value: String) -> String {
        value.replacingOccurrences(of: "&amp;", with: "&").replacingOccurrences(of: "&lt;", with: "<").replacingOccurrences(of: "&gt;", with: ">").replacingOccurrences(of: "&quot;", with: "\"")
            .split(whereSeparator: \.isWhitespace).joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
