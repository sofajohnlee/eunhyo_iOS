import SwiftUI

struct ContentView: View {
    @AppStorage("selectedGrade") private var selectedGrade = GradeLevel.elementary.rawValue

    var body: some View {
        NavigationStack {
            List {
                Section("학교급 선택") {
                    ForEach(GradeLevel.allCases) { grade in
                        NavigationLink { SchoolMenuView(grade: grade) } label: { Label(grade.rawValue, systemImage: icon(for: grade)) }
                            .simultaneousGesture(TapGesture().onEnded { selectedGrade = grade.rawValue })
                    }
                }
                Section("바로 학습") {
                    NavigationLink("영어 학습", destination: EnglishStudyView())
                    NavigationLink("국어 학습", destination: KoreanStudyView())
                    NavigationLink("수학 학습", destination: MathStudyView())
                    NavigationLink("한자 학습", destination: HanjaStudyView())
                }
                Section("Android 기능 이식") {
                    NavigationLink { FullFeatureMenuView() } label: { Label("전체 학습 기능", systemImage: "square.grid.2x2") }
                    NavigationLink("AI 학습 채팅", destination: AIChatView())
                    NavigationLink("PDF 자료실", destination: PdfLibraryView())
                    NavigationLink("그림 연습", destination: DrawingPracticeView())
                    NavigationLink("영어 문장 가져오기", destination: EnglishSentenceImportView())
                }
                Section {
                    NavigationLink("설정", destination: SettingsView())
                    NavigationLink("앱 정보", destination: AboutView())
                }
            }
            .navigationTitle("은효 학습")
            .safeAreaInset(edge: .bottom) { Text("선택 학년: \(selectedGrade)").font(.footnote).foregroundStyle(.secondary).padding(8) }
        }
    }

    private func icon(for grade: GradeLevel) -> String {
        switch grade { case .elementary: "1.circle"; case .middle: "2.circle"; case .high: "3.circle" }
    }
}

struct SchoolMenuView: View {
    let grade: GradeLevel
    var body: some View {
        List {
            Section("학교급 핵심 과목") {
                ForEach(SchoolCatalog.entries(for: grade)) { item in
                    NavigationLink { SectionRouterView(section: item.section) } label: {
                        VStack(alignment: .leading, spacing: 4) { Text(item.title).font(.headline); Text(item.description).font(.subheadline).foregroundStyle(.secondary) }
                    }
                }
            }
            Section("확장 학습") {
                NavigationLink("전체 학습 기능", destination: FullFeatureMenuView())
                NavigationLink("AI 학습 채팅", destination: AIChatView())
                NavigationLink("알파벳 따라쓰기", destination: AlphabetTraceView())
                NavigationLink("파닉스", destination: PhonicsColorView())
                NavigationLink("영어 단어 연습", destination: EnglishWordPracticeView())
                NavigationLink("영어 문장 가져오기", destination: EnglishSentenceImportView())
                NavigationLink("PDF 자료실", destination: PdfLibraryView())
                NavigationLink("그림 연습", destination: DrawingPracticeView())
                NavigationLink("맞춤법 연습", destination: KoreanSpellingPracticeView())
                NavigationLink("관용 표현", destination: KoreanIdiomPracticeView())
                NavigationLink("최대공약수·최소공배수", destination: GcdLcmView())
                NavigationLink("단위와 측정", destination: ExtendedMeasurementView())
                NavigationLink("교육 링크", destination: EducationLinksView())
                NavigationLink("스포츠", destination: SportsView())
                NavigationLink("마술", destination: MagicView())
                NavigationLink("타자 연습", destination: TypingPracticeView())
                NavigationLink("미로", destination: MazePracticeView())
                NavigationLink("보드게임 점수", destination: BoardGameScoreView())
            }
        }.navigationTitle("\(grade.rawValue) 학습")
    }
}

struct SectionRouterView: View {
    let section: SchoolSection
    @ViewBuilder var body: some View {
        switch section {
        case .korean: KoreanStudyView()
        case .english: EnglishStudyView()
        case .math: MathStudyView()
        case .hanja: HanjaStudyView()
        case .history: HistoryStudyView()
        case .utilities: UtilitiesView()
        }
    }
}
