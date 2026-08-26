import SwiftUI
import UniformTypeIdentifiers

struct PdfLibraryView: View {
    @State private var importing = false
    @State private var selectedName = "선택된 PDF 없음"
    var body: some View {
        Form {
            Section("영어 전문가 PDF 자료") {
                Text("원본처럼 시스템 파일 선택기에서 PDF를 선택합니다.")
                Button("PDF 선택") { importing = true }
                Text(selectedName).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("PDF 자료실")
        .fileImporter(isPresented: $importing, allowedContentTypes: [.pdf]) { result in
            if case .success(let url) = result { selectedName = url.lastPathComponent }
        }
    }
}

struct DrawingStroke: Identifiable { let id = UUID(); var points: [CGPoint] }

struct DrawingPracticeView: View {
    @State private var strokes: [DrawingStroke] = []
    @State private var current: [CGPoint] = []
    var body: some View {
        VStack(spacing: 12) {
            Canvas { context, _ in
                for stroke in strokes { draw(stroke.points, in: &context) }
                draw(current, in: &context)
            }
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.3)))
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in current.append(value.location) }
                .onEnded { _ in if !current.isEmpty { strokes.append(.init(points: current)); current = [] } })
            HStack {
                Button("마지막 획 취소") { if !strokes.isEmpty { strokes.removeLast() } }
                Spacer()
                Button("전체 지우기", role: .destructive) { strokes.removeAll(); current.removeAll() }
            }
        }.padding().navigationTitle("그림 연습")
    }
    private func draw(_ points: [CGPoint], in context: inout GraphicsContext) {
        guard let first = points.first else { return }
        var path = Path(); path.move(to: first)
        for p in points.dropFirst() { path.addLine(to: p) }
        context.stroke(path, with: .foreground, lineWidth: 6)
    }
}

struct PhonicsColorView: View {
    private let groups = [("black", ["black","cat","apple"]),("red",["red","dress","elephant"]),("green",["green","tea","feet"]),("blue",["blue","moon","zoo"])]
    @State private var group = 0
    @State private var word = 0
    private var currentWords: [String] { groups[group].1 }
    var body: some View {
        VStack(spacing: 24) {
            Text("색상 그룹: \(groups[group].0)").font(.headline)
            Text(currentWords[word]).font(.system(size: 56, weight: .bold))
            Button("발음 듣기") { SpeechService.shared.speak(currentWords[word], language: "en-US") }
            HStack { Button("이전 단어") { word = (word - 1 + currentWords.count) % currentWords.count }; Button("다음 단어") { word = (word + 1) % currentWords.count } }
            HStack { Button("이전 그룹") { group = (group - 1 + groups.count) % groups.count; word = 0 }; Button("다음 그룹") { group = (group + 1) % groups.count; word = 0 } }
            Text("기본 데이터 · 원본 CSV 확장 대상").font(.caption).foregroundStyle(.secondary)
        }.padding().navigationTitle("파닉스")
    }
}

struct EnglishSentenceEntryIOS: Codable, Identifiable {
    let id = UUID(); let sentence: String; let meaning: String; let note: String
    enum CodingKeys: String, CodingKey { case sentence, meaning, note }
}

struct EnglishSentenceImportView: View {
    @State private var importing = false
    @State private var entries: [EnglishSentenceEntryIOS] = []
    @State private var status = "CSV를 선택하세요."
    var body: some View {
        List {
            Section { Button("CSV 선택") { importing = true }; Text(status).foregroundStyle(.secondary) }
            Section("미리보기") {
                ForEach(entries.prefix(10)) { item in
                    VStack(alignment: .leading) { Text(item.sentence).font(.headline); Text(item.meaning); if !item.note.isEmpty { Text(item.note).font(.caption).foregroundStyle(.secondary) } }
                }
            }
            if !entries.isEmpty { Button("앱 내부에 저장") { save(); status = "\(entries.count)개 문장을 저장했습니다." } }
        }
        .navigationTitle("영어 문장 가져오기")
        .fileImporter(isPresented: $importing, allowedContentTypes: [.commaSeparatedText, .plainText]) { result in
            guard case .success(let url) = result else { return }
            let access = url.startAccessingSecurityScopedResource(); defer { if access { url.stopAccessingSecurityScopedResource() } }
            if let text = try? String(contentsOf: url, encoding: .utf8) { entries = parseCSV(text); status = "\(entries.count)개 문장을 가져왔습니다." }
        }
        .onAppear { load() }
    }
    private func parseCSV(_ text: String) -> [EnglishSentenceEntryIOS] {
        text.split(whereSeparator: \.isNewline).compactMap { line in
            let cols = splitCSV(String(line)); guard cols.count >= 4 else { return nil }
            return .init(sentence: cols[1].trimmingCharacters(in: .whitespaces), meaning: cols[2].trimmingCharacters(in: .whitespaces), note: cols[3].trimmingCharacters(in: .whitespaces))
        }
    }
    private func splitCSV(_ line: String) -> [String] {
        var result:[String]=[]; var current=""; var quoted=false; let chars=Array(line); var i=0
        while i < chars.count { let c=chars[i]; if c == "\"" { if quoted && i+1 < chars.count && chars[i+1] == "\"" { current.append("\""); i += 1 } else { quoted.toggle() } } else if c == "," && !quoted { result.append(current); current="" } else { current.append(c) }; i += 1 }
        result.append(current); return result
    }
    private func save() { if let data = try? JSONEncoder().encode(entries) { UserDefaults.standard.set(data, forKey: "englishSentenceEntries") } }
    private func load() { if let data = UserDefaults.standard.data(forKey: "englishSentenceEntries"), let value = try? JSONDecoder().decode([EnglishSentenceEntryIOS].self, from: data) { entries = value; status = "저장된 문장 \(value.count)개를 불러왔습니다." } }
}

struct EducationLinksView: View {
    let links:[(String,String,String)] = [
        ("국어·한자","사이버서당","https://www.cyberseodang.or.kr/"),
        ("수학 개념","소수(개념)","https://www.khanacademy.org/math/pre-algebra/pre-algebra-factors-multiples/modal/v/prime-numbers"),
        ("수학 개념","최대공약수(개념)","https://www.khanacademy.org/math/pre-algebra/pre-algebra-factors-multiples/modal/v/greatest-common-divisor-factor-exercise"),
        ("기하","피타고라스 정리","https://www.khanacademy.org/math/basic-geo/basic-geometry-pythagorean-theorem/modal/v/the-pythagorean-theorem"),
        ("영어 문법","영문법: 명사","https://www.khanacademy.org/humanities/grammar/parts-of-speech-the-noun/"),
        ("초등 수학","초등 시계","https://www.khanacademy.org/math/cc-2nd-grade-math/cc-2nd-measurement-data/cc-2nd-time")
    ]
    var body: some View { List { ForEach(Array(Dictionary(grouping: links, by:{$0.0}).keys).sorted(), id:\.self) { group in Section(group) { ForEach(links.filter{$0.0==group}, id:\.1) { item in Link(item.1, destination: URL(string:item.2)!) } } } }.navigationTitle("교육 링크") }
}

struct SportsView: View {
    let videos=[("줄넘기","vVctfW2OCyQ"),("배드민턴","hFf6P-mXEG4"),("탁구","XcVOUkNzhVg")]
    var body: some View { List(videos, id:\.0) { item in Link(item.0, destination: URL(string:"https://www.youtube.com/watch?v=\(item.1)")!) }.navigationTitle("스포츠") }
}

struct MagicView: View {
    let videos=[("동전상자","m1YJfwayYe0"),("그림액자","IFaHpDhY6gc"),("체인지백","u3E90wZVFME"),("우유컵","uLoA8PzR9TU"),("요술상자","URSYZpbyEV0"),("카드","karU105_Z7c"),("덥립","6W85Wwqjyss"),("지팡이","IXqPRj_dfcg"),("딜라이트","WftXZiMKoFM"),("로프","MWQwDYP3NHs")]
    var body: some View { List(Array(videos.enumerated()), id:\.offset) { index,item in Link("\(index+1). \(item.0)", destination: URL(string:"https://www.youtube.com/watch?v=\(item.1)")!) }.navigationTitle("마술") }
}
