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
            Section("수학·도형") {
                NavigationLink("최대공약수·최소공배수", destination: GcdLcmView())
                NavigationLink("단위와 측정", destination: ExtendedMeasurementView())
                NavigationLink("도형 학습", destination: GeometryStudyView())
                NavigationLink("그래프 도구", destination: GraphToolsView())
            }
            Section("한자·세계") {
                NavigationLink("한자 부수", destination: HanjaRadicalView())
                NavigationLink("세계 여러 나라", destination: CountryStudyView())
            }
            Section("퀴즈·게임") {
                NavigationLink("OX 골든벨", destination: GoldenBellView())
                NavigationLink("놀이형 성향 테스트", destination: PersonalityQuizView())
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
        if normalized.contains("안녕") || normalized.contains("hello") { return "안녕하세요! 은효 학습 도우미예요. 국어, 영어, 수학, 한자 중 무엇을 공부할까요?" }
        if normalized.contains("영어") || normalized.contains("english") { return "영어 메뉴에서는 알파벳, 단어와 발음 연습을 할 수 있어요." }
        if normalized.contains("수학") || normalized.contains("math") { return "수학 메뉴에서 사칙연산 문제를 풀고 최대공약수와 최소공배수도 연습해 보세요." }
        if normalized.contains("한자") { return "한자 메뉴에서는 글자와 뜻을 보고 음성으로 읽어볼 수 있어요." }
        if normalized.contains("국어") || normalized.contains("맞춤법") { return "국어 메뉴에서 맞춤법과 관용 표현을 연습할 수 있어요." }
        if normalized.contains("고마") || normalized.contains("thank") { return "천만에요. 다음 문제도 같이 해봐요!" }
        return "\"\(input)\"에 대해 학습 중이에요. 핵심 단어를 포함해 조금 더 구체적으로 질문해 주세요."
    }
}

struct AIChatView: View {
    @State private var input = ""
    @State private var messages: [AIChatMessage] = [.init(text: "안녕하세요! 무엇을 공부할까요?", isUser: false)]
    private let engine = LocalStudyChatEngine()
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
                }.onChange(of: messages.count) { _, _ in if let id = messages.last?.id { withAnimation { proxy.scrollTo(id, anchor: .bottom) } } }
            }
            Divider()
            HStack { TextField("질문을 입력하세요", text: $input); Button("보내기") { send() }.disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) }.padding()
        }.navigationTitle("AI 학습 채팅")
    }
    private func send() { let text = input.trimmingCharacters(in: .whitespacesAndNewlines); guard !text.isEmpty else { return }; messages.append(.init(text: text, isUser: true)); input = ""; messages.append(.init(text: engine.reply(to: text), isUser: false)) }
}

struct AlphabetTraceView: View {
    @State private var index = 0
    private let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    var body: some View { VStack(spacing: 24) { Text(String(letters[index])).font(.system(size: 150, weight: .bold)); Text("손가락으로 글자의 모양을 따라 써 보세요.").foregroundStyle(.secondary); Button("발음 듣기") { SpeechService.shared.speak(String(letters[index]), language: "en-US") }; HStack { Button("이전") { index = (index - 1 + letters.count) % letters.count }; Spacer(); Button("다음") { index = (index + 1) % letters.count } } }.padding().navigationTitle("알파벳 따라쓰기") }
}

struct EnglishWordPracticeView: View {
    private let words = [("apple","사과"),("book","책"),("cat","고양이"),("dog","개"),("friend","친구"),("school","학교"),("study","공부하다"),("happy","행복한")]
    @State private var index = 0; @State private var showMeaning = false
    var body: some View { VStack(spacing: 25) { Text(words[index].0).font(.system(size: 52, weight: .bold)); if showMeaning { Text(words[index].1).font(.title) }; Button("발음 듣기") { SpeechService.shared.speak(words[index].0, language: "en-US") }; Button(showMeaning ? "뜻 숨기기" : "뜻 보기") { showMeaning.toggle() }; Button("다음 단어") { index = (index + 1) % words.count; showMeaning = false } }.padding().navigationTitle("영어 단어") }
}

struct KoreanSpellingPracticeView: View {
    private let questions = [("오늘 숙제를 다 ___ 집에 갔다.",["하고","하구"],0),("비가 와서 우산을 ___ 왔다.",["가지고","갖이고"],0),("그렇게 하면 ___ 돼.",["안","않"],0),("숙제를 다 ___?",["했니","햇니"],0)]
    @State private var index = 0; @State private var result = ""
    var body: some View { VStack(spacing: 24) { Text(questions[index].0).font(.title2).multilineTextAlignment(.center); ForEach(Array(questions[index].1.enumerated()), id: \.offset) { i, option in Button(option) { result = i == questions[index].2 ? "정답입니다!" : "다시 생각해 보세요." }.buttonStyle(.borderedProminent) }; Text(result).font(.headline); Button("다음") { index = (index + 1) % questions.count; result = "" } }.padding().navigationTitle("맞춤법 연습") }
}

struct KoreanIdiomPracticeView: View {
    private let idioms = [("발이 넓다","아는 사람이 많고 교제 범위가 넓다."),("눈이 높다","좋은 것만 고르는 기준이 높다."),("손이 크다","씀씀이가 크거나 음식을 많이 준비한다."),("입이 무겁다","비밀을 잘 지킨다."),("귀가 얇다","남의 말을 쉽게 믿는다.")]
    @State private var index = 0
    var body: some View { VStack(spacing: 24) { Text(idioms[index].0).font(.largeTitle.bold()); Text(idioms[index].1).font(.title3).multilineTextAlignment(.center); Button("읽어주기") { SpeechService.shared.speak("\(idioms[index].0). \(idioms[index].1)") }; Button("다음 표현") { index = (index + 1) % idioms.count } }.padding().navigationTitle("관용 표현") }
}

struct GcdLcmView: View {
    @State private var first = "12"; @State private var second = "18"
    private var a: Int { max(0, Int(first) ?? 0) }; private var b: Int { max(0, Int(second) ?? 0) }
    private func gcd(_ x: Int,_ y: Int) -> Int { var a=x,b=y; while b != 0 { let r=a%b; a=b; b=r }; return a }
    private var g: Int { gcd(a,b) }; private var l: Int { guard a != 0 && b != 0 else { return 0 }; return a/g*b }
    var body: some View { Form { Section("두 수") { TextField("첫 번째 수", text:$first).keyboardType(.numberPad); TextField("두 번째 수", text:$second).keyboardType(.numberPad) }; Section("결과") { LabeledContent("최대공약수", value:"\(g)"); LabeledContent("최소공배수", value:"\(l)") } }.navigationTitle("최대공약수·최소공배수") }
}

struct ExtendedMeasurementView: View {
    @State private var value = "100"; @State private var mode = 0
    private var number: Double { Double(value) ?? 0 }
    private var output: String { switch mode { case 0: return "\(number / 100) m"; case 1: return "\(number * 100) cm"; case 2: return "\(number / 1000) kg"; default: return "\(number * 1000) g" } }
    var body: some View { Form { Picker("변환", selection:$mode) { Text("cm → m").tag(0); Text("m → cm").tag(1); Text("g → kg").tag(2); Text("kg → g").tag(3) }; TextField("값", text:$value).keyboardType(.decimalPad); Section("결과") { Text(output).font(.title2.bold()) } }.navigationTitle("단위와 측정") }
}

struct TypingPracticeView: View {
    private let samples = ["오늘도 즐겁게 공부해요.","Practice makes progress.","책을 읽고 생각을 나누어요.","SwiftUI로 재미있는 앱을 만들어요."]
    @State private var target = "오늘도 즐겁게 공부해요."; @State private var typed = ""; @State private var message = ""
    var body: some View { Form { Section("따라 입력") { Text(target).font(.title3.bold()); TextField("여기에 입력하세요", text:$typed, axis:.vertical); Button("확인") { message = typed == target ? "정확합니다!" : "다른 부분이 있어요." }; Text(message) }; Button("새 문장") { target = samples.randomElement()!; typed=""; message="" } }.navigationTitle("타자 연습") }
}

struct MazePracticeView: View {
    private let maze = ["S □ ■ □ □","■ □ ■ □ ■","□ □ □ □ ■","□ ■ ■ □ □","□ □ □ ■ G"]
    var body: some View { VStack(spacing:16) { Text("S에서 G까지 길을 찾아보세요.").font(.headline); ForEach(maze,id:\.self) { Text($0).font(.system(.title2, design:.monospaced)) }; Text("■은 지나갈 수 없는 벽입니다.").foregroundStyle(.secondary) }.padding().navigationTitle("미로") }
}

struct BoardGameScoreView: View {
    @State private var player1="은효"; @State private var player2="친구"; @State private var score1=0; @State private var score2=0
    var body: some View { Form { Section("참가자") { TextField("1번", text:$player1); TextField("2번", text:$player2) }; Section("점수") { HStack { Text("\(player1): \(score1)"); Spacer(); Button("+1") { score1 += 1 } }; HStack { Text("\(player2): \(score2)"); Spacer(); Button("+1") { score2 += 1 } } }; Button("점수 초기화", role:.destructive) { score1=0; score2=0 } }.navigationTitle("보드게임 점수") }
}
