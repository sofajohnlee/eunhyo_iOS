import SwiftUI

// MARK: - Geometry

enum GeometryCategory: String, CaseIterable, Identifiable {
    case circle = "원"
    case triangle = "삼각형"
    case rectangle = "사각형"
    case solid = "입체도형"
    var id: String { rawValue }
}

struct GeometryItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}

enum GeometryCatalog {
    static func items(for category: GeometryCategory) -> [GeometryItem] {
        switch category {
        case .circle:
            return [.init(title: "원", description: "중심에서 같은 거리에 있는 점들의 모임"), .init(title: "반지름", description: "원의 중심에서 원 위의 한 점까지의 거리"), .init(title: "지름", description: "원의 중심을 지나 원 위의 두 점을 잇는 선분")]
        case .triangle:
            return [.init(title: "정삼각형", description: "세 변의 길이가 같은 삼각형"), .init(title: "이등변삼각형", description: "두 변의 길이가 같은 삼각형"), .init(title: "직각삼각형", description: "한 각이 90도인 삼각형")]
        case .rectangle:
            return [.init(title: "정사각형", description: "네 변의 길이가 같고 네 각이 직각인 사각형"), .init(title: "직사각형", description: "네 각이 모두 직각인 사각형"), .init(title: "평행사변형", description: "두 쌍의 대변이 각각 평행한 사각형")]
        case .solid:
            return [.init(title: "정육면체", description: "모든 면이 합동인 정사각형인 입체도형"), .init(title: "직육면체", description: "모든 면이 직사각형인 입체도형"), .init(title: "원기둥", description: "서로 평행한 두 원을 밑면으로 하는 입체도형")]
        }
    }
}

struct GeometryStudyView: View {
    @State private var category: GeometryCategory = .circle
    @State private var index = 0
    private var items: [GeometryItem] { GeometryCatalog.items(for: category) }
    private var item: GeometryItem { items[min(index, items.count - 1)] }

    var body: some View {
        VStack(spacing: 24) {
            Picker("도형", selection: $category) {
                ForEach(GeometryCategory.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: category) { _, _ in index = 0 }

            GeometryPreview(category: category)
                .frame(height: 220)

            Text(item.title).font(.title.bold())
            Text(item.description).multilineTextAlignment(.center).foregroundStyle(.secondary)

            HStack {
                Button("이전") { index = (index - 1 + items.count) % items.count }
                Spacer()
                Text("\(index + 1) / \(items.count)")
                Spacer()
                Button("다음") { index = (index + 1) % items.count }
            }
        }
        .padding()
        .navigationTitle("도형 학습")
    }
}

struct GeometryPreview: View {
    let category: GeometryCategory
    var body: some View {
        Canvas { context, size in
            let rect = CGRect(x: size.width * 0.2, y: size.height * 0.15, width: size.width * 0.6, height: size.height * 0.7)
            var path = Path()
            switch category {
            case .circle:
                path.addEllipse(in: rect)
            case .triangle:
                path.move(to: CGPoint(x: size.width / 2, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.closeSubpath()
            case .rectangle:
                path.addRect(rect)
            case .solid:
                path.addRect(rect)
                let offset: CGFloat = 28
                path.move(to: CGPoint(x: rect.minX, y: rect.minY)); path.addLine(to: CGPoint(x: rect.minX + offset, y: rect.minY - offset))
                path.addLine(to: CGPoint(x: rect.maxX + offset, y: rect.minY - offset)); path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                path.move(to: CGPoint(x: rect.maxX, y: rect.maxY)); path.addLine(to: CGPoint(x: rect.maxX + offset, y: rect.maxY - offset)); path.addLine(to: CGPoint(x: rect.maxX + offset, y: rect.minY - offset))
            }
            context.stroke(path, with: .foreground, lineWidth: 4)
        }
    }
}

// MARK: - Golden Bell

struct GoldenBellQuestion { let text: String; let answer: Bool }

enum GoldenBellRepository {
    static let questions = [
        GoldenBellQuestion(text: "세계에서 가장 넓은 나라는 러시아이다.", answer: true),
        GoldenBellQuestion(text: "세계에서 인구가 10억 명이 넘는 나라는 중국과 인도이다.", answer: true),
        GoldenBellQuestion(text: "세계에서 가장 작은 나라는 바티칸시티이다.", answer: true),
        GoldenBellQuestion(text: "8 더하기 4 는 12이다.", answer: true),
        GoldenBellQuestion(text: "9 더하기 9 는 8이다.", answer: false),
        GoldenBellQuestion(text: "7 더하기 5 는 13이다.", answer: false),
        GoldenBellQuestion(text: "지구는 태양 주위를 돈다.", answer: true),
        GoldenBellQuestion(text: "지구는 달의 주위를 돈다.", answer: false),
        GoldenBellQuestion(text: "지구는 스스로 회전한다.", answer: true),
        GoldenBellQuestion(text: "여성 최초의 노벨상 수상자는 마리 퀴리이다.", answer: true),
        GoldenBellQuestion(text: "세계에서 가장 높은 산은 에베레스트이다.", answer: true),
        GoldenBellQuestion(text: "레미제라블의 주인공은 장발장이다.", answer: true),
        GoldenBellQuestion(text: "미국의 초대 대통령은 조지 워싱턴이다.", answer: true),
        GoldenBellQuestion(text: "미국은 55개의 주로 이루어졌다.", answer: false),
        GoldenBellQuestion(text: "독일의 수도는 파리이다.", answer: false),
        GoldenBellQuestion(text: "일본의 수도는 도쿄이다.", answer: true),
        GoldenBellQuestion(text: "중국의 수도는 베이징이다.", answer: true)
    ]
}

struct GoldenBellView: View {
    @State private var index = 0
    @State private var score = 0
    @State private var answered = false
    @State private var result = ""
    private var question: GoldenBellQuestion { GoldenBellRepository.questions[index] }

    var body: some View {
        VStack(spacing: 28) {
            Text("OX 골든벨").font(.largeTitle.bold())
            Text("문제 \(index + 1) / \(GoldenBellRepository.questions.count) · 점수 \(score)").foregroundStyle(.secondary)
            Text(question.text).font(.title2).multilineTextAlignment(.center).frame(minHeight: 120)
            HStack(spacing: 36) {
                Button("O") { answer(true) }.buttonStyle(.borderedProminent).font(.largeTitle)
                Button("X") { answer(false) }.buttonStyle(.borderedProminent).font(.largeTitle)
            }.disabled(answered)
            Text(result).font(.headline).frame(height: 30)
            if answered {
                Button(index == GoldenBellRepository.questions.count - 1 ? "처음부터" : "다음 문제") { next() }
            }
        }.padding().navigationTitle("골든벨")
    }

    private func answer(_ value: Bool) {
        answered = true
        if value == question.answer { score += 1; result = "정답입니다!" } else { result = "아쉽습니다. 다시 기억해 두세요." }
    }
    private func next() {
        if index == GoldenBellRepository.questions.count - 1 { index = 0; score = 0 } else { index += 1 }
        answered = false; result = ""
    }
}

// MARK: - Countries

struct CountryEntry: Identifiable {
    let id = UUID(); let name: String; let region: String; let capital: String
}

enum CountryRepository {
    static let countries = [
        CountryEntry(name:"대한민국", region:"동아시아", capital:"서울"), CountryEntry(name:"일본", region:"동아시아", capital:"도쿄"), CountryEntry(name:"중국", region:"동아시아", capital:"베이징"), CountryEntry(name:"몽골", region:"동아시아", capital:"울란바토르"),
        CountryEntry(name:"인도", region:"남아시아", capital:"뉴델리"), CountryEntry(name:"네팔", region:"남아시아", capital:"카트만두"), CountryEntry(name:"태국", region:"동남아시아", capital:"방콕"), CountryEntry(name:"베트남", region:"동남아시아", capital:"하노이"), CountryEntry(name:"싱가포르", region:"동남아시아", capital:"싱가포르"), CountryEntry(name:"인도네시아", region:"동남아시아", capital:"자카르타"),
        CountryEntry(name:"호주", region:"오세아니아", capital:"캔버라"), CountryEntry(name:"뉴질랜드", region:"오세아니아", capital:"웰링턴"), CountryEntry(name:"미국", region:"북아메리카", capital:"워싱턴 D.C."), CountryEntry(name:"캐나다", region:"북아메리카", capital:"오타와"), CountryEntry(name:"멕시코", region:"북아메리카", capital:"멕시코시티"),
        CountryEntry(name:"브라질", region:"남아메리카", capital:"브라질리아"), CountryEntry(name:"아르헨티나", region:"남아메리카", capital:"부에노스아이레스"), CountryEntry(name:"칠레", region:"남아메리카", capital:"산티아고"), CountryEntry(name:"영국", region:"유럽", capital:"런던"), CountryEntry(name:"프랑스", region:"유럽", capital:"파리"), CountryEntry(name:"독일", region:"유럽", capital:"베를린"), CountryEntry(name:"이탈리아", region:"유럽", capital:"로마"), CountryEntry(name:"스페인", region:"유럽", capital:"마드리드"), CountryEntry(name:"스위스", region:"유럽", capital:"베른"),
        CountryEntry(name:"이집트", region:"북아프리카", capital:"카이로"), CountryEntry(name:"남아프리카 공화국", region:"남아프리카", capital:"프리토리아"), CountryEntry(name:"케냐", region:"동아프리카", capital:"나이로비"), CountryEntry(name:"나이지리아", region:"서아프리카", capital:"아부자"), CountryEntry(name:"사우디아라비아", region:"서아시아", capital:"리야드"), CountryEntry(name:"튀르키예", region:"서아시아·유럽", capital:"앙카라")
    ]
}

struct CountryStudyView: View {
    @State private var query = ""
    private var filtered: [CountryEntry] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return CountryRepository.countries }
        return CountryRepository.countries.filter { $0.name.localizedCaseInsensitiveContains(query) || $0.region.localizedCaseInsensitiveContains(query) || $0.capital.localizedCaseInsensitiveContains(query) }
    }
    var body: some View {
        List(filtered) { country in
            VStack(alignment: .leading, spacing: 5) {
                Text(country.name).font(.headline)
                Text("\(country.region) · 수도: \(country.capital)").foregroundStyle(.secondary)
            }
        }.searchable(text: $query, prompt: "나라·지역·수도 검색").navigationTitle("세계 여러 나라")
    }
}

// MARK: - Hanja radicals

struct HanjaRadicalEntry: Identifiable { let id = UUID(); let character: String; let reading: String; let meaning: String }
struct HanjaRadicalGroup: Identifiable { let id: Int; let title: String; let entries: [HanjaRadicalEntry] }

enum HanjaRadicalRepositoryIOS {
    static let groups = [
        HanjaRadicalGroup(id: 1, title: "사람·몸", entries: [.init(character:"人", reading:"인", meaning:"사람"), .init(character:"口", reading:"구", meaning:"입"), .init(character:"心", reading:"심", meaning:"마음"), .init(character:"手", reading:"수", meaning:"손")]),
        HanjaRadicalGroup(id: 2, title: "자연", entries: [.init(character:"日", reading:"일", meaning:"해"), .init(character:"月", reading:"월", meaning:"달"), .init(character:"山", reading:"산", meaning:"산"), .init(character:"水", reading:"수", meaning:"물")]),
        HanjaRadicalGroup(id: 3, title: "생활", entries: [.init(character:"木", reading:"목", meaning:"나무"), .init(character:"火", reading:"화", meaning:"불"), .init(character:"田", reading:"전", meaning:"밭"), .init(character:"門", reading:"문", meaning:"문")]),
        HanjaRadicalGroup(id: 4, title: "방향·수", entries: [.init(character:"上", reading:"상", meaning:"위"), .init(character:"下", reading:"하", meaning:"아래"), .init(character:"一", reading:"일", meaning:"하나"), .init(character:"十", reading:"십", meaning:"열")])
    ]
}

struct HanjaRadicalView: View {
    var body: some View {
        List {
            ForEach(HanjaRadicalRepositoryIOS.groups) { group in
                Section(group.title) {
                    ForEach(group.entries) { entry in
                        HStack {
                            Text(entry.character).font(.largeTitle).frame(width: 55)
                            VStack(alignment: .leading) { Text("\(entry.meaning) \(entry.reading)"); Text("부수 학습").font(.caption).foregroundStyle(.secondary) }
                            Spacer()
                            Button { SpeechService.shared.speak("\(entry.meaning) \(entry.reading)") } label: { Image(systemName: "speaker.wave.2") }
                        }
                    }
                }
            }
        }.navigationTitle("한자 부수")
    }
}

// MARK: - Personality play quiz

struct PersonalityQuizView: View {
    @State private var q1 = false; @State private var q2 = false; @State private var q3 = false; @State private var q4 = false
    @State private var result = ""
    var body: some View {
        Form {
            Section {
                Text("교육용 놀이 기능이며 심리검사나 진단이 아닙니다.").foregroundStyle(.secondary)
            }
            Section("질문") {
                Toggle("사람들과 함께하는 활동을 좋아한다", isOn: $q1)
                Toggle("새로운 생각과 가능성을 떠올리는 것을 좋아한다", isOn: $q2)
                Toggle("결정할 때 논리와 기준을 중요하게 생각한다", isOn: $q3)
                Toggle("계획을 정해 두고 진행하는 것을 좋아한다", isOn: $q4)
            }
            Button("결과 보기") { result = personalityResult() }
            if !result.isEmpty { Section("결과") { Text(result).font(.title2.bold()) } }
        }.navigationTitle("놀이형 성향 테스트")
    }
    private func personalityResult() -> String {
        if !q1 { return "내향형 성향" }
        switch (q2,q3,q4) {
        case (true,true,true): return "외향형 성향"
        case (true,true,false): return "직관형 성향"
        case (true,false,true): return "사고형 성향"
        case (true,false,false): return "인식형 성향"
        case (false,true,true): return "감각형 성향"
        case (false,true,false): return "판단형 성향"
        case (false,false,true): return "감성형 성향"
        default: return "내향형 성향"
        }
    }
}

// MARK: - Graph tools

struct GraphToolsView: View {
    var body: some View {
        List {
            Section("그래프 도구") {
                Link(destination: URL(string: "https://www.desmos.com/calculator")!) {
                    Label("Desmos 그래프 계산기 열기", systemImage: "chart.xyaxis.line")
                }
            }
            Section { Text("Android 원본의 외부 브라우저 연결 기능을 iOS Link로 이식했습니다.").foregroundStyle(.secondary) }
        }.navigationTitle("그래프")
    }
}
