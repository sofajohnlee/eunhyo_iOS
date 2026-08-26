import SwiftUI

struct FullFeatureMenuView: View {
    var body: some View {
        List {
            Section("AI") {
                NavigationLink("AI 학습 채팅", destination: AIChatView())
            }
            Section("영어") {
                NavigationLink("알파벳 따라쓰기", destination: AlphabetTraceView())
                NavigationLink("영어 단어 연습", destination: EnglishWordPracticeView())
            }
            Section("국어") {
                NavigationLink("맞춤법 연습", destination: KoreanSpellingPracticeView())
                NavigationLink("관용 표현", destination: KoreanIdiomPracticeView())
            }
            Section("수학") {
                NavigationLink("최대공약수·최소공배수", destination: GcdLcmView())
                NavigationLink("단위와 측정", destination: ExtendedMeasurementView())
            }
            Section("학습 도구·게임") {
                NavigationLink("타자 연습", destination: TypingPracticeView())
                NavigationLink("미로", destination: MazePracticeView())
                NavigationLink("보드게임 점수", destination: BoardGameScoreView())
            }
        }
        .navigationTitle("전체 학습 기능")
    }
}

// MARK: - AI chat

struct AIChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

struct LocalStudyChatEngine {
    func reply(to input: String) -> String {
        let normalized = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized.isEmpty { return "질문을 입력해 주세요." }
        if normalized.contains("안녕") || normalized.contains("hello") {
            return "안녕하세요! 은효 학습 도우미예요. 국어, 영어, 수학, 한자 중 무엇을 공부할까요?"
        }
        if normalized.contains("영어") || normalized.contains("english") {
            return "영어 메뉴에서는 알파벳, 단어와 발음 연습을 할 수 있어요."
        }
        if normalized.contains("수학") || normalized.contains("math") {
            return "수학 메뉴에서 사칙연산 문제를 풀고 최대공약수와 최소공배수도 연습해 보세요."
        }
        if normalized.contains("한자") {
            return "한자 메뉴에서는 글자와 뜻을 보고 음성으로 읽어볼 수 있어요."
        }
        if normalized.contains("국어") || normalized.contains("맞춤법") {
            return "국어 메뉴에서 맞춤법과 관용 표현을 연습할 수 있어요."
        }
        if normalized.contains("고마") || normalized.contains("thank") {
            return "천만에요. 다음 문제도 같이 해봐요!"
        }
        return "\"\(input)\"에 대해 학습 중이에요. 핵심 단어를 포함해 조금 더 구체적으로 질문해 주세요."
    }
}

struct AIChatView: View {
    @State private var input = ""
    @State private var messages: [AIChatMessage] = [
        .init(text: "안녕하세요! 무엇을 공부할까요?", isUser: false)
    ]
    private let engine = LocalStudyChatEngine()

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser { Spacer(minLength: 50) }
                                Text(message.text)
                                    .padding(12)
                                    .background(message.isUser ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                if !message.isUser { Spacer(minLength: 50) }
                            }
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages) { _, newValue in
                    if let last = newValue.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            Divider()
            HStack {
                TextField("메시지 입력", text: $input)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(send)
                Button("전송", action: send)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("AI 학습 채팅")
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(.init(text: text, isUser: true))
        messages.append(.init(text: engine.reply(to: text), isUser: false))
        input = ""
    }
}

// MARK: - English

struct AlphabetTraceView: View {
    private let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    @State private var index = 0
    @State private var path = Path()

    var body: some View {
        VStack(spacing: 16) {
            Picker("알파벳", selection: $index) {
                ForEach(letters.indices, id: \.self) { Text(String(letters[$0])).tag($0) }
            }
            .pickerStyle(.wheel)
            .frame(height: 100)

            ZStack {
                Text(String(letters[index]))
                    .font(.system(size: 220, weight: .bold))
                    .foregroundStyle(.secondary.opacity(0.18))
                Canvas { context, _ in
                    context.stroke(path, with: .color(.primary), lineWidth: 7)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if path.isEmpty { path.move(to: value.location) }
                            else { path.addLine(to: value.location) }
                        }
                )
            }
            .frame(height: 340)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18))

            HStack {
                Button("지우기") { path = Path() }
                Button("발음") { SpeechService.shared.speak(String(letters[index]), language: "en-US") }
                Button("다음") {
                    index = (index + 1) % letters.count
                    path = Path()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("알파벳 따라쓰기")
    }
}

struct EnglishWordPracticeView: View {
    private let words: [(String, String)] = [
        ("apple", "사과"), ("book", "책"), ("cat", "고양이"), ("dog", "개"),
        ("family", "가족"), ("friend", "친구"), ("school", "학교"), ("water", "물")
    ]
    @State private var index = 0
    @State private var showMeaning = false

    var body: some View {
        VStack(spacing: 24) {
            Text(words[index].0).font(.system(size: 52, weight: .bold))
            if showMeaning { Text(words[index].1).font(.title2) }
            Button(showMeaning ? "뜻 숨기기" : "뜻 보기") { showMeaning.toggle() }
            Button("발음 듣기") { SpeechService.shared.speak(words[index].0, language: "en-US") }
            HStack {
                Button("이전") { move(-1) }
                Button("다음") { move(1) }
            }
        }
        .padding()
        .navigationTitle("영어 단어")
    }

    private func move(_ delta: Int) {
        index = (index + delta + words.count) % words.count
        showMeaning = false
    }
}

// MARK: - Korean

struct KoreanSpellingPracticeView: View {
    private let questions: [(String, String, [String])] = [
        ("오늘 숙제를 다 ___.", "했다", ["했다", "햇다"]),
        ("비가 와도 학교에 ___.", "간다", ["간다", "갖다"]),
        ("문을 꼭 ___.", "닫아", ["닫아", "다아"]),
        ("그러면 ___.", "안 돼", ["안 돼", "안 되"])
    ]
    @State private var index = 0
    @State private var feedback = ""

    var body: some View {
        VStack(spacing: 24) {
            Text(questions[index].0).font(.title2.bold())
            ForEach(questions[index].2, id: \.self) { option in
                Button(option) {
                    feedback = option == questions[index].1 ? "정답입니다!" : "다시 생각해 보세요."
                }
                .buttonStyle(.borderedProminent)
            }
            Text(feedback).foregroundStyle(.secondary)
            Button("다음 문제") {
                index = (index + 1) % questions.count
                feedback = ""
            }
        }
        .padding()
        .navigationTitle("맞춤법 연습")
    }
}

struct KoreanIdiomPracticeView: View {
    private let items = [
        ("발이 넓다", "아는 사람이 많다"),
        ("눈이 높다", "기준이나 기대가 높다"),
        ("귀가 얇다", "남의 말을 쉽게 믿는다"),
        ("손이 크다", "씀씀이가 크거나 음식을 많이 준비한다")
    ]
    @State private var index = 0
    @State private var reveal = false

    var body: some View {
        VStack(spacing: 24) {
            Text(items[index].0).font(.largeTitle.bold())
            if reveal { Text(items[index].1).font(.title3) }
            Button(reveal ? "뜻 숨기기" : "뜻 보기") { reveal.toggle() }
            Button("읽어주기") { SpeechService.shared.speak(items[index].0) }
            Button("다음") {
                index = (index + 1) % items.count
                reveal = false
            }
        }
        .padding()
        .navigationTitle("관용 표현")
    }
}

// MARK: - Math

struct GcdLcmView: View {
    @State private var first = "12"
    @State private var second = "18"

    var a: Int { max(0, Int(first) ?? 0) }
    var b: Int { max(0, Int(second) ?? 0) }
    var gcd: Int { Self.gcd(a, b) }
    var lcm: Int { (a == 0 || b == 0) ? 0 : abs(a / max(gcd, 1) * b) }

    var body: some View {
        Form {
            TextField("첫 번째 수", text: $first).keyboardType(.numberPad)
            TextField("두 번째 수", text: $second).keyboardType(.numberPad)
            Section("결과") {
                LabeledContent("최대공약수", value: "\(gcd)")
                LabeledContent("최소공배수", value: "\(lcm)")
            }
        }
        .navigationTitle("최대공약수·최소공배수")
    }

    static func gcd(_ x: Int, _ y: Int) -> Int {
        var a = abs(x), b = abs(y)
        while b != 0 { (a, b) = (b, a % b) }
        return a
    }
}

struct ExtendedMeasurementView: View {
    enum UnitMode: String, CaseIterable, Identifiable {
        case length = "길이"
        case mass = "무게"
        var id: String { rawValue }
    }
    @State private var mode: UnitMode = .length
    @State private var input = "100"

    var value: Double { Double(input) ?? 0 }

    var body: some View {
        Form {
            Picker("종류", selection: $mode) {
                ForEach(UnitMode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            TextField(mode == .length ? "센티미터(cm)" : "그램(g)", text: $input)
                .keyboardType(.decimalPad)
            if mode == .length {
                LabeledContent("미터(m)", value: String(format: "%.3f", value / 100))
                LabeledContent("킬로미터(km)", value: String(format: "%.5f", value / 100_000))
            } else {
                LabeledContent("킬로그램(kg)", value: String(format: "%.3f", value / 1000))
            }
        }
        .navigationTitle("단위와 측정")
    }
}

// MARK: - Typing / games

struct TypingPracticeView: View {
    private let samples = [
        "오늘도 즐겁게 공부해요.",
        "Practice makes progress.",
        "차근차근 배우면 실력이 늘어요.",
        "The quick brown fox jumps over the lazy dog."
    ]
    @State private var sampleIndex = 0
    @State private var typed = ""
    @State private var startedAt: Date?

    var target: String { samples[sampleIndex] }
    var accuracy: Int {
        guard !typed.isEmpty else { return 0 }
        let pairs = zip(typed, target)
        let correct = pairs.filter { $0 == $1 }.count
        return Int(Double(correct) / Double(max(typed.count, 1)) * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(target).font(.title3.bold())
            TextEditor(text: $typed)
                .frame(height: 150)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.secondary.opacity(0.3)))
                .onChange(of: typed) { oldValue, newValue in
                    if oldValue.isEmpty && !newValue.isEmpty { startedAt = Date() }
                }
            LabeledContent("정확도", value: "\(accuracy)%")
            if let startedAt {
                LabeledContent("경과", value: "\(Int(Date().timeIntervalSince(startedAt)))초")
            }
            HStack {
                Button("초기화") { typed = ""; startedAt = nil }
                Button("다음 문장") {
                    sampleIndex = (sampleIndex + 1) % samples.count
                    typed = ""; startedAt = nil
                }
            }
            Spacer()
        }
        .padding()
        .navigationTitle("타자 연습")
    }
}

struct MazePracticeView: View {
    private let size = 7
    @State private var player = CGPoint(x: 0, y: 0)
    private let walls: Set<String> = ["1,0", "1,1", "3,1", "3,2", "5,2", "2,3", "3,3", "5,4", "1,5", "2,5"]

    var body: some View {
        VStack(spacing: 18) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: size), spacing: 2) {
                ForEach(0..<(size * size), id: \.self) { idx in
                    let x = idx % size
                    let y = idx / size
                    ZStack {
                        Rectangle().fill(cellColor(x: x, y: y))
                        if x == size - 1 && y == size - 1 { Image(systemName: "flag.checkered") }
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
            }
            .padding(8)
            .background(.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(spacing: 8) {
                Button("↑") { move(dx: 0, dy: -1) }
                HStack { Button("←") { move(dx: -1, dy: 0) }; Button("↓") { move(dx: 0, dy: 1) }; Button("→") { move(dx: 1, dy: 0) } }
            }
            .buttonStyle(.borderedProminent)
            Button("처음부터") { player = CGPoint(x: 0, y: 0) }
        }
        .padding()
        .navigationTitle("미로")
    }

    private func key(_ x: Int, _ y: Int) -> String { "\(x),\(y)" }
    private func cellColor(x: Int, y: Int) -> Color {
        if Int(player.x) == x && Int(player.y) == y { return .accentColor.opacity(0.5) }
        if walls.contains(key(x, y)) { return .secondary.opacity(0.55) }
        return .secondary.opacity(0.08)
    }
    private func move(dx: Int, dy: Int) {
        let nx = Int(player.x) + dx, ny = Int(player.y) + dy
        guard nx >= 0, ny >= 0, nx < size, ny < size, !walls.contains(key(nx, ny)) else { return }
        player = CGPoint(x: nx, y: ny)
    }
}

struct BoardGameScoreView: View {
    @State private var player1 = ""
    @State private var player2 = ""
    @State private var score1 = 0
    @State private var score2 = 0

    var body: some View {
        Form {
            Section("플레이어 1") {
                TextField("이름", text: $player1)
                Stepper("점수: \(score1)", value: $score1)
            }
            Section("플레이어 2") {
                TextField("이름", text: $player2)
                Stepper("점수: \(score2)", value: $score2)
            }
            Section {
                Text(score1 == score2 ? "현재 동점" : (score1 > score2 ? "\(player1.isEmpty ? "플레이어 1" : player1) 우세" : "\(player2.isEmpty ? "플레이어 2" : player2) 우세"))
                Button("점수 초기화", role: .destructive) { score1 = 0; score2 = 0 }
            }
        }
        .navigationTitle("보드게임 점수")
    }
}
