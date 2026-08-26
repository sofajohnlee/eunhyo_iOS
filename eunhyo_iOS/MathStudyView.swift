import SwiftUI

struct MathStudyView: View {
    @State private var operation: MathOperation = .add
    @State private var difficulty: MathDifficulty = .intermediate
    @State private var problem = MathProblemGenerator.generate(operation: .add, difficulty: .intermediate)
    @State private var answer = ""
    @State private var message = ""
    @AppStorage("mathCorrect") private var correct = 0
    @AppStorage("mathAttempts") private var attempts = 0

    var body: some View {
        Form {
            Picker("연산", selection: $operation) {
                ForEach(MathOperation.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: operation) { _, _ in next() }

            Picker("난이도", selection: $difficulty) {
                ForEach(MathDifficulty.allCases) { Text($0.rawValue).tag($0) }
            }
            .onChange(of: difficulty) { _, _ in next() }

            Section("문제") {
                Text(problem.prompt).font(.largeTitle.bold())
                TextField("정답", text: $answer).keyboardType(.numberPad)
                Button("채점") {
                    attempts += 1
                    if Int(answer) == problem.answer {
                        correct += 1
                        message = "정답입니다!"
                    } else {
                        message = "정답은 \(problem.answer)입니다."
                    }
                }.buttonStyle(.borderedProminent)
                if !message.isEmpty { Text(message) }
                Button("다음 문제") { next() }
            }

            Section("진행") {
                LabeledContent("정답", value: "\(correct)")
                LabeledContent("시도", value: "\(attempts)")
            }
        }
        .navigationTitle("수학")
    }

    private func next() {
        problem = MathProblemGenerator.generate(operation: operation, difficulty: difficulty)
        answer = ""
        message = ""
    }
}
