import SwiftUI
import UniformTypeIdentifiers

// MARK: - Korean Book

enum StoryPlot: Int, CaseIterable, Identifiable {
    case happy = 1, funny = 2, moving = 3
    var id: Int { rawValue }
    var title: String { switch self { case .happy: "행복한 이야기"; case .funny: "재미있는 이야기"; case .moving: "감동적인 이야기" } }
}

enum StoryLanguage: Int, CaseIterable, Identifiable {
    case korean = 1, english = 2
    var id: Int { rawValue }
    var title: String { self == .korean ? "한국어" : "English" }
}

struct KoreanBookView: View {
    private let characters = ["유진","푸른아리 선생님","미아","스테파니","올리비아","엠마","안드레아","쥬쥬","로사","아이린","바넬로피","개구리","개구리"]
    @AppStorage("bookCharacter") private var character = 1
    @AppStorage("bookPlot") private var plotRaw = 1
    @AppStorage("bookLanguage") private var languageRaw = 1

    private var plot: StoryPlot { StoryPlot(rawValue: plotRaw) ?? .happy }
    private var language: StoryLanguage { StoryLanguage(rawValue: languageRaw) ?? .korean }
    private var story: String { makeStory(character: character, plot: plot, language: language) }

    var body: some View {
        Form {
            Section("이야기 설정") {
                Picker("주인공", selection: $character) {
                    ForEach(1...13, id: \.self) { i in Text(characters[i-1]).tag(i) }
                }
                Picker("분위기", selection: $plotRaw) {
                    ForEach(StoryPlot.allCases) { Text($0.title).tag($0.rawValue) }
                }
                Picker("언어", selection: $languageRaw) {
                    ForEach(StoryLanguage.allCases) { Text($0.title).tag($0.rawValue) }
                }
            }
            Section("이야기") {
                Text(story)
                Button("읽어주기") { SpeechService.shared.speak(story, language: language == .korean ? "ko-KR" : "en-US") }
                NavigationLink("이야기 편집", destination: KoreanBookEditorView(initialText: story, language: language))
            }
        }
        .navigationTitle("한글책")
    }

    private func makeStory(character: Int, plot: StoryPlot, language: StoryLanguage) -> String {
        let koNames = characters
        let enNames = ["Yujin Princess","White Princess","Aurora Princess","Cinderella Princess","Rapunzel Princess","Elsa Princess","Anna Princess","Princess Marie","Princess Marie's mom","Fairy","Vanellope","The Frog Prince","The Frog Prince"]
        if language == .korean {
            if character == 1 && plot == .happy { return "요즘 유진이는 그리기가 너무 좋아요. 그리고 그 날은 푸른아리선생님을 볼 수 있기 때문이죠. 선생님, 사랑해요. 엄마, 아빠도요^^" }
            if character == 2 && plot == .happy { return "푸른아리 선생님은 매주 화요일마다 유진이를 만나서 너무 행복해요. 매일 만나고 싶어서 유진이가 푸른아리반으로 왔으면 좋겠어요. 선생님이 유진이를 사랑하고 있나봐요." }
            if character == 1 && plot == .funny { return "유진이는 어제 자면서 발차기를 했어요. 축구하는 꿈을 꿨을까요? 아니면 혹시 ..." }
            if character == 2 && plot == .funny { return "푸른아리선생님은 요즘 소리내어 웃는 일이 많아요. 그건 바로 ..." }
            if character == 1 && plot == .moving { return "유진이는 푸른아리선생님이 인사를 하면 너무 가슴이 두근두근 뛰고 감동이 밀려온대요. 어떻게 된 일일까요?" }
            if character == 2 && plot == .moving { return "푸른아리선생님은 화요일마다 유진이의 인사를 받으면 너무 감동이 밀려온답니다. 유진이가 너무 좋은데 어떡하죠?" }
            let name = koNames[max(0, min(character-1, koNames.count-1))]
            switch plot { case .happy: return "\(name)는 유진이를 만나서 행복했어요."; case .funny: return "\(name)는 유진이를 만나서 웃음이 나왔어요."; case .moving: return "\(name)에게 어떤 감동적인 이야기가 이어질까요?" }
        } else {
            if character == 1 && plot == .happy { return "Once upon a time, there was a Yujin Princess. Someday she had a stomachache. But she was brave and intelligent. The next day, she went to the children's hospital, took medicine, and soon felt better. She was happy because she was thinking of having fun with her daddy." }
            let name = enNames[max(0, min(character-1, enNames.count-1))]
            switch plot { case .happy: return "Once upon a time, there was \(name). Which happy story is there?"; case .funny: return "Once upon a time, there was \(name). Which funny story is there?"; case .moving: return "Once upon a time, there was \(name). Which moving story is there?" }
        }
    }
}

struct KoreanBookEditorView: View {
    @State private var text: String
    let language: StoryLanguage
    init(initialText: String, language: StoryLanguage) { _text = State(initialValue: initialText); self.language = language }
    var body: some View {
        VStack(spacing: 16) {
            TextEditor(text: $text).frame(minHeight: 220).padding(6).overlay(RoundedRectangle(cornerRadius: 10).stroke(.secondary.opacity(0.3)))
            ScrollView { Text(text).frame(maxWidth: .infinity, alignment: .leading).padding() }.background(.secondary.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 10))
            Button("읽어주기") { SpeechService.shared.speak(text, language: language == .korean ? "ko-KR" : "en-US") }.buttonStyle(.borderedProminent)
        }.padding().navigationTitle("이야기 편집")
    }
}

// MARK: - Media

struct LearningMediaItem: Identifiable { let id = UUID(); let title: String; let videoID: String; let group: String }

enum LearningMediaCatalog {
    static let items: [LearningMediaItem] = [
        .init(title:"Cactus", videoID:"rlwfd1ZaDJ4", group:"용기·학습"), .init(title:"Drawing", videoID:"rw_qPB7PV8k", group:"용기·학습"), .init(title:"Dream Song", videoID:"kGsUHbq3yUY", group:"용기·학습"), .init(title:"세계의 인사", videoID:"GpTR1wF4M6k", group:"용기·학습"), .init(title:"친구들과 놀기", videoID:"vP5Be3Aq6ls", group:"용기·학습"), .init(title:"안나 그리기", videoID:"Vb6-xmXVpU0", group:"그리기"), .init(title:"울라프 그리기", videoID:"WQk6dJ7I59A", group:"그리기"), .init(title:"크리스토프 그리기", videoID:"Ab8meURjPyw", group:"그리기"), .init(title:"스벤 그리기", videoID:"JEgbzY2inqo", group:"그리기"), .init(title:"Flynn Rider 그리기", videoID:"vTBZCtct6Rw", group:"그리기"),
        .init(title:"중국어 배우기", videoID:"QtaBQvv8u3c", group:"언어"), .init(title:"일본어 배우기", videoID:"PQrg_4_BKBQ", group:"언어"), .init(title:"스페인어 배우기", videoID:"fmWjDL2Spvw", group:"언어"), .init(title:"좋은 친구란", videoID:"avHdx18pi_U", group:"생활"), .init(title:"자신감 갖기", videoID:"id6N8rWdW5U", group:"생활"),
        .init(title:"징글벨", videoID:"3CWJNqyub3o", group:"크리스마스"), .init(title:"기쁘다 구주 오셨네", videoID:"30OaM6b48k8", group:"크리스마스"), .init(title:"고요한 밤", videoID:"nEH7_2c644Q", group:"크리스마스"), .init(title:"노엘", videoID:"D5uud2fjtoo", group:"크리스마스"), .init(title:"눈사람", videoID:"KhjfskHJf1o", group:"크리스마스"), .init(title:"루돌프", videoID:"0byH9h1ClBY", group:"크리스마스"), .init(title:"White Christmas", videoID:"UioEvXY7xoM", group:"크리스마스"), .init(title:"실버벨", videoID:"FI0kKtySvKE", group:"크리스마스"), .init(title:"탄일종", videoID:"R5Q2bmIMIjo", group:"크리스마스"),
        .init(title:"Wreck-It Ralph", videoID:"3posPWuA9Ss", group:"기타"), .init(title:"국어 문장 영상", videoID:"NG2aBtqazkY", group:"기타"), .init(title:"Marie / Snow 영상", videoID:"wKF-nyaBDiw", group:"기타")
    ]
}

struct MediaLibraryView: View {
    @State private var query = ""
    private var filtered: [LearningMediaItem] { query.isEmpty ? LearningMediaCatalog.items : LearningMediaCatalog.items.filter { $0.title.localizedCaseInsensitiveContains(query) || $0.group.localizedCaseInsensitiveContains(query) } }
    var body: some View {
        List(filtered) { item in
            Link(destination: URL(string: "https://www.youtube.com/watch?v=\(item.videoID)")!) {
                VStack(alignment: .leading) { Text(item.title).font(.headline); Text(item.group).font(.caption).foregroundStyle(.secondary) }
            }
        }.searchable(text: $query).navigationTitle("미디어 자료실")
    }
}

// MARK: - Math progress & state

struct MathProgressDashboardView: View {
    @AppStorage("mathCorrect") private var correct = 0
    @AppStorage("mathAttempts") private var attempts = 0
    @AppStorage("mathState") private var state = 0
    private var accuracy: Int { attempts == 0 ? 0 : correct * 100 / attempts }
    private var stateLabel: String { switch state { case 1: "1 · 집중"; case 2: "2 · 보통"; case 3: "3 · 복습 필요"; case 4: "4 · 휴식 권장"; default: "0 · 미설정" } }
    var body: some View {
        Form {
            Section("학습 진도") { LabeledContent("정답", value: "\(correct)"); LabeledContent("시도", value: "\(attempts)"); LabeledContent("정답률", value: "\(accuracy)%") }
            Section("학습 상태") { Text(stateLabel); Picker("상태", selection: $state) { Text("미설정").tag(0); Text("집중").tag(1); Text("보통").tag(2); Text("복습 필요").tag(3); Text("휴식 권장").tag(4) } }
            Button("진도 초기화", role: .destructive) { correct = 0; attempts = 0; state = 0 }
        }.navigationTitle("수학 진도·상태")
    }
}

// MARK: - Backup / restore

struct BackupPayload: Codable {
    var selectedGrade: String
    var mathCorrect: Int
    var mathAttempts: Int
    var mathState: Int
    var studyNote: String
    var bookCharacter: Int
    var bookPlot: Int
    var bookLanguage: Int
    var savedEnglishSentences: String
}

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data
    init(data: Data = Data()) { self.data = data }
    init(configuration: ReadConfiguration) throws { data = configuration.file.regularFileContents ?? Data() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}

struct DataTransferView: View {
    @AppStorage("selectedGrade") private var selectedGrade = GradeLevel.elementary.rawValue
    @AppStorage("mathCorrect") private var mathCorrect = 0
    @AppStorage("mathAttempts") private var mathAttempts = 0
    @AppStorage("mathState") private var mathState = 0
    @AppStorage("studyNote") private var studyNote = ""
    @AppStorage("bookCharacter") private var bookCharacter = 1
    @AppStorage("bookPlot") private var bookPlot = 1
    @AppStorage("bookLanguage") private var bookLanguage = 1
    @AppStorage("englishSentencesJSON") private var englishSentencesJSON = ""
    @State private var exporting = false
    @State private var importing = false
    @State private var exportDocument = BackupDocument()
    @State private var status = ""

    var body: some View {
        Form {
            Section("백업") {
                Button("학습 데이터 내보내기") { prepareExport() }
                Text("설정, 수학 진도, 메모, 한글책 설정, 영어 문장 저장 데이터를 JSON으로 백업합니다.").font(.caption).foregroundStyle(.secondary)
            }
            Section("복원") { Button("백업 파일 가져오기") { importing = true } }
            if !status.isEmpty { Section("상태") { Text(status) } }
        }
        .navigationTitle("데이터 백업·복원")
        .fileExporter(isPresented: $exporting, document: exportDocument, contentType: .json, defaultFilename: "eunhyo_backup") { result in status = result.isSuccess ? "백업 파일을 저장했습니다." : "백업 저장에 실패했습니다." }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
            do { let url = try result.get(); let access = url.startAccessingSecurityScopedResource(); defer { if access { url.stopAccessingSecurityScopedResource() } }; let data = try Data(contentsOf: url); let payload = try JSONDecoder().decode(BackupPayload.self, from: data); restore(payload); status = "백업 데이터를 복원했습니다." } catch { status = "백업 파일을 읽을 수 없습니다." }
        }
    }

    private func prepareExport() {
        let payload = BackupPayload(selectedGrade: selectedGrade, mathCorrect: mathCorrect, mathAttempts: mathAttempts, mathState: mathState, studyNote: studyNote, bookCharacter: bookCharacter, bookPlot: bookPlot, bookLanguage: bookLanguage, savedEnglishSentences: englishSentencesJSON)
        if let data = try? JSONEncoder().encode(payload) { exportDocument = BackupDocument(data: data); exporting = true }
    }
    private func restore(_ p: BackupPayload) { selectedGrade = p.selectedGrade; mathCorrect = p.mathCorrect; mathAttempts = p.mathAttempts; mathState = min(4,max(0,p.mathState)); studyNote = p.studyNote; bookCharacter = min(13,max(1,p.bookCharacter)); bookPlot = min(3,max(1,p.bookPlot)); bookLanguage = min(2,max(1,p.bookLanguage)); englishSentencesJSON = p.savedEnglishSentences }
}
