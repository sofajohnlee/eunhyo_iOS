import SwiftUI
import AVFoundation

final class SpeechService {
    static let shared = SpeechService()
    private let synthesizer = AVSpeechSynthesizer()
    func speak(_ text: String, language: String = "ko-KR") {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.45
        synthesizer.speak(utterance)
    }
}

struct EnglishStudyView: View {
    private let words = ["apple", "book", "cat", "dog", "school", "friend", "happy", "study"]
    @State private var index = 0
    var body: some View {
        VStack(spacing: 28) {
            Text("영어 학습").font(.largeTitle.bold())
            Text(words[index]).font(.system(size: 54, weight: .bold))
            Button("발음 듣기") { SpeechService.shared.speak(words[index], language: "en-US") }
                .buttonStyle(.borderedProminent)
            HStack {
                Button("이전") { index = (index - 1 + words.count) % words.count }
                Button("다음") { index = (index + 1) % words.count }
            }
        }.padding().navigationTitle("영어")
    }
}

struct KoreanStudyView: View {
    private let cards = [
        ("맞춤법", "되/돼, 안/않 등 자주 틀리는 표현을 익혀요."),
        ("관용 표현", "뜻을 문맥 속에서 이해해요."),
        ("발음", "표준 발음을 듣고 따라 해요."),
        ("문장", "짧은 문장을 읽고 직접 만들어 봐요.")
    ]
    var body: some View {
        List(cards, id: \.0) { card in
            VStack(alignment: .leading, spacing: 6) {
                Text(card.0).font(.headline)
                Text(card.1).foregroundStyle(.secondary)
                Button("읽어주기") { SpeechService.shared.speak(card.1) }
            }.padding(.vertical, 4)
        }.navigationTitle("국어")
    }
}

struct HanjaStudyView: View {
    private let items = [("日", "날 일"), ("月", "달 월"), ("山", "메 산"), ("水", "물 수"), ("火", "불 화"), ("木", "나무 목"), ("人", "사람 인"), ("學", "배울 학")]
    @State private var index = 0
    var body: some View {
        VStack(spacing: 24) {
            Text(items[index].0).font(.system(size: 90, weight: .bold))
            Text(items[index].1).font(.title2)
            Button("뜻 읽기") { SpeechService.shared.speak(items[index].1) }
            HStack {
                Button("이전") { index = (index - 1 + items.count) % items.count }
                Button("다음") { index = (index + 1) % items.count }
            }
        }.padding().navigationTitle("한자")
    }
}

struct HistoryStudyView: View {
    let entries = ["선사 시대와 고조선", "삼국과 가야", "고려", "조선", "근대 사회", "대한민국"]
    var body: some View {
        List(entries, id: \.self) { Label($0, systemImage: "book.closed") }
            .navigationTitle("역사")
    }
}

struct UtilitiesView: View {
    var body: some View {
        List {
            NavigationLink("시계 학습", destination: ClockStudyView())
            NavigationLink("단위 변환", destination: MeasurementView())
            NavigationLink("간단 메모", destination: StudyNoteView())
        }.navigationTitle("학습 도구")
    }
}

struct ClockStudyView: View {
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            VStack(spacing: 24) {
                Image(systemName: "clock").font(.system(size: 100))
                Text(context.date.formatted(date: .omitted, time: .standard)).font(.largeTitle.monospacedDigit())
            }.padding()
        }.navigationTitle("시계 학습")
    }
}

struct MeasurementView: View {
    @State private var cm = ""
    var meters: Double { (Double(cm) ?? 0) / 100.0 }
    var body: some View {
        Form {
            TextField("센티미터(cm)", text: $cm).keyboardType(.decimalPad)
            LabeledContent("미터(m)", value: String(format: "%.2f", meters))
        }.navigationTitle("단위 변환")
    }
}

struct StudyNoteView: View {
    @AppStorage("studyNote") private var note = ""
    var body: some View { TextEditor(text: $note).padding().navigationTitle("학습 메모") }
}
