import SwiftUI

struct ContentView: View {
    @AppStorage("selectedGrade") private var selectedGrade = GradeLevel.elementary.rawValue

    var body: some View {
        NavigationStack {
            List {
                Section("학교급 선택") {
                    ForEach(GradeLevel.allCases) { grade in
                        NavigationLink {
                            SchoolMenuView(grade: grade)
                        } label: {
                            Label(grade.rawValue, systemImage: icon(for: grade))
                        }
                        .simultaneousGesture(TapGesture().onEnded { selectedGrade = grade.rawValue })
                    }
                }
                Section("바로 학습") {
                    NavigationLink("영어 학습", destination: EnglishStudyView())
                    NavigationLink("국어 학습", destination: KoreanStudyView())
                    NavigationLink("수학 학습", destination: MathStudyView())
                    NavigationLink("한자 학습", destination: HanjaStudyView())
                }
                Section {
                    NavigationLink("설정", destination: SettingsView())
                    NavigationLink("앱 정보", destination: AboutView())
                }
            }
            .navigationTitle("은효 학습")
            .safeAreaInset(edge: .bottom) {
                Text("선택 학년: \(selectedGrade)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
        }
    }

    private func icon(for grade: GradeLevel) -> String {
        switch grade {
        case .elementary: "1.circle"
        case .middle: "2.circle"
        case .high: "3.circle"
        }
    }
}

struct SchoolMenuView: View {
    let grade: GradeLevel
    var body: some View {
        List(SchoolCatalog.entries(for: grade)) { item in
            NavigationLink {
                SectionRouterView(section: item.section)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title).font(.headline)
                    Text(item.description).font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("\(grade.rawValue) 학습")
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
