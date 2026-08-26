import SwiftUI
import Foundation

struct AIMLMatch {
    let stars: [String]
}

enum AIMLPatternMatcher {
    static func match(pattern: String, input: String) -> AIMLMatch? {
        let tokens = pattern.split(whereSeparator: \.isWhitespace).map(String.init)
        let words = input.split(whereSeparator: \.isWhitespace).map(String.init)
        return matchFrom(tokens: tokens, words: words, tokenIndex: 0, wordIndex: 0, stars: [])
    }

    private static func matchFrom(tokens: [String], words: [String], tokenIndex: Int, wordIndex: Int, stars: [String]) -> AIMLMatch? {
        if tokenIndex == tokens.count {
            return wordIndex == words.count ? AIMLMatch(stars: stars) : nil
        }
        let token = tokens[tokenIndex]
        if token != "*" && token != "_" {
            guard wordIndex < words.count, token.caseInsensitiveCompare(words[wordIndex]) == .orderedSame else { return nil }
            return matchFrom(tokens: tokens, words: words, tokenIndex: tokenIndex + 1, wordIndex: wordIndex + 1, stars: stars)
        }
        let minimum = token == "_" ? 1 : 0
        guard wordIndex + minimum <= words.count else { return nil }
        for end in stride(from: words.count, through: wordIndex + minimum, by: -1) {
            let capture = words[wordIndex..<end].joined(separator: " ")
            if let result = matchFrom(tokens: tokens, words: words, tokenIndex: tokenIndex + 1, wordIndex: end, stars: stars + [capture]) { return result }
        }
        return nil
    }
}

struct AIMLSubstitutionTable {
    var substitutions: [(String, String)]
    static let empty = AIMLSubstitutionTable(substitutions: [])

    func apply(_ value: String) -> String {
        var result = " \(value) "
        for (from, to) in substitutions {
            result = result.replacingOccurrences(of: from, with: to, options: [.caseInsensitive])
        }
        return result.split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    static func parse(_ text: String) -> AIMLSubstitutionTable {
        let rows = text.split(whereSeparator: \.isNewline).compactMap { raw -> (String, String)? in
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty, !line.hasPrefix("#") else { return nil }
            let fields = splitCSV(line)
            guard fields.count >= 2, !fields[0].isEmpty else { return nil }
            return (fields[0], fields[1])
        }
        return AIMLSubstitutionTable(substitutions: rows)
    }

    private static func splitCSV(_ line: String) -> [String] {
        var result: [String] = [], current = "", quoted = false
        let chars = Array(line); var i = 0
        while i < chars.count {
            let c = chars[i]
            if c == "\"" {
                if quoted && i + 1 < chars.count && chars[i + 1] == "\"" { current.append("\""); i += 1 }
                else { quoted.toggle() }
            } else if c == "," && !quoted { result.append(current); current = "" }
            else { current.append(c) }
            i += 1
        }
        result.append(current)
        return result
    }
}

final class AIMLPredicateStore {
    private var values: [String: String]
    init(values: [String: String] = [:]) { self.values = values }
    func get(_ name: String) -> String { values[normalize(name)] ?? "" }
    @discardableResult func set(_ name: String, _ value: String) -> String { let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines); values[normalize(name)] = cleaned; return cleaned }
    var topic: String { let value = get("topic"); return value.isEmpty ? "unknown" : value }
    private func normalize(_ name: String) -> String { name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
}

struct AIMLCategory {
    let pattern: String
    let template: String
}

final class SwiftAIMLChatEngine {
    private let predicates = AIMLPredicateStore(values: ["name": "친구", "topic": "unknown"])
    private let normalizer = AIMLSubstitutionTable(substitutions: [
        (" what's ", " what is "), (" i'm ", " i am "), (" can't ", " cannot "), (" 안녕! ", " 안녕 ")
    ])
    private let categories: [AIMLCategory] = [
        .init(pattern: "안녕", template: "안녕하세요! 은효 학습 도우미예요."),
        .init(pattern: "내 이름은 *", template: "반가워요, {star1}! 이름을 기억할게요."),
        .init(pattern: "내 이름이 뭐야", template: "제가 기억하는 이름은 {name}예요."),
        .init(pattern: "수학 *", template: "수학 질문이군요. {star1} 부분을 차근차근 살펴봐요."),
        .init(pattern: "영어 *", template: "영어 학습에서는 {star1}을(를) 연습해 볼 수 있어요."),
        .init(pattern: "한자 *", template: "한자 학습 주제는 {star1}이군요. 글자와 뜻을 함께 익혀봐요."),
        .init(pattern: "국어 *", template: "국어 학습에서 {star1}을(를) 함께 살펴봐요."),
        .init(pattern: "고마워", template: "천만에요. 계속 공부해 봐요!"),
        .init(pattern: "*", template: "{star1}에 대해 조금 더 구체적으로 질문해 주세요.")
    ]

    func reply(to rawInput: String) -> String {
        let input = normalizer.apply(rawInput.trimmingCharacters(in: .whitespacesAndNewlines))
        if input.isEmpty { return "질문을 입력해 주세요." }
        for category in categories {
            if let match = AIMLPatternMatcher.match(pattern: category.pattern, input: input) {
                if category.pattern == "내 이름은 *", let name = match.stars.first { predicates.set("name", name) }
                return render(category.template, stars: match.stars)
            }
        }
        return "다시 말해 주세요."
    }

    private func render(_ template: String, stars: [String]) -> String {
        var output = template.replacingOccurrences(of: "{name}", with: predicates.get("name"))
        for (index, value) in stars.enumerated() { output = output.replacingOccurrences(of: "{star\(index + 1)}", with: value) }
        return output
    }
}

struct AIMLChatView: View {
    @State private var input = ""
    @State private var messages: [AIChatMessage] = [.init(text: "AIML 호환 학습 채팅입니다. 무엇을 공부할까요?", isUser: false)]
    @State private var engine = SwiftAIMLChatEngine()

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser { Spacer(minLength: 50) }
                                Text(message.text).padding(10).background(message.isUser ? Color.accentColor.opacity(0.16) : Color.secondary.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 12))
                                if !message.isUser { Spacer(minLength: 50) }
                            }.id(message.id)
                        }
                    }.padding()
                }
                .onChange(of: messages.count) { _, _ in if let id = messages.last?.id { proxy.scrollTo(id, anchor: .bottom) } }
            }
            Divider()
            HStack {
                TextField("질문을 입력하세요", text: $input)
                Button("보내기") { send() }.disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }.padding()
        }.navigationTitle("AIML 학습 채팅")
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(.init(text: text, isUser: true)); input = ""
        messages.append(.init(text: engine.reply(to: text), isUser: false))
    }
}

struct InteractiveGeometryView: View {
    @State private var radius: Double = 70
    @State private var rotation: Double = 0
    var body: some View {
        Form {
            Section("도형 조작") {
                VStack {
                    Canvas { context, size in
                        let center = CGPoint(x: size.width/2, y: size.height/2)
                        var path = Path()
                        for i in 0..<3 {
                            let angle = (Double(i) * 120 + rotation - 90) * .pi / 180
                            let point = CGPoint(x: center.x + CGFloat(cos(angle) * radius), y: center.y + CGFloat(sin(angle) * radius))
                            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
                        }
                        path.closeSubpath(); context.stroke(path, with: .foreground, lineWidth: 4)
                    }.frame(height: 260)
                    Slider(value: $radius, in: 30...110) { Text("크기") }
                    Slider(value: $rotation, in: 0...360) { Text("회전") }
                }
            }
            Section { LabeledContent("반경", value: "\(Int(radius))"); LabeledContent("회전", value: "\(Int(rotation))°") }
        }.navigationTitle("도형 조작")
    }
}
