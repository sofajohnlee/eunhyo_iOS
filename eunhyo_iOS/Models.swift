import Foundation

enum GradeLevel: String, CaseIterable, Identifiable {
    case elementary = "초등"
    case middle = "중등"
    case high = "고등"
    var id: String { rawValue }
}

enum SchoolSection: String, CaseIterable, Identifiable {
    case korean = "국어"
    case english = "영어"
    case math = "수학"
    case hanja = "한자"
    case history = "역사"
    case utilities = "학습 도구"
    var id: String { rawValue }
}

struct SchoolEntry: Identifiable {
    let id = UUID()
    let section: SchoolSection
    let title: String
    let description: String
}

enum SchoolCatalog {
    static func entries(for grade: GradeLevel) -> [SchoolEntry] {
        switch grade {
        case .elementary:
            return [
                .init(section: .korean, title: "한글·문장·동요", description: "글자, 문장, 동요와 책 만들기"),
                .init(section: .english, title: "영어 기초", description: "알파벳, 단어, 문장 학습"),
                .init(section: .math, title: "초등 수학", description: "사칙연산, 도형, 단위와 측정"),
                .init(section: .hanja, title: "한자", description: "급수별 한자와 부수 학습"),
                .init(section: .history, title: "역사", description: "초등 역사 학습"),
                .init(section: .utilities, title: "학습 도구", description: "시계와 기타 학습 도구")
            ]
        case .middle:
            return [
                .init(section: .korean, title: "중등 국어", description: "문법, 관용 표현, 읽기"),
                .init(section: .english, title: "중등 영어", description: "문장과 어휘 학습"),
                .init(section: .math, title: "중등 수학", description: "수와 연산, 도형, 그래프"),
                .init(section: .hanja, title: "한자", description: "한자 및 사자소학 학습"),
                .init(section: .history, title: "역사", description: "한국사와 세계사 학습")
            ]
        case .high:
            return [
                .init(section: .korean, title: "고등 국어", description: "문법과 읽기 학습"),
                .init(section: .english, title: "고등 영어", description: "고급 문장과 어휘 학습"),
                .init(section: .math, title: "고등 수학", description: "수학 문제와 그래프 학습"),
                .init(section: .hanja, title: "한자", description: "고급 한자 학습"),
                .init(section: .history, title: "역사", description: "역사 심화 학습")
            ]
        }
    }
}

enum MathOperation: String, CaseIterable, Identifiable {
    case add = "+"
    case subtract = "−"
    case multiply = "×"
    case divide = "÷"
    var id: String { rawValue }
}

enum MathDifficulty: String, CaseIterable, Identifiable {
    case beginner = "초급"
    case intermediate = "중급"
    case advanced = "고급"
    var id: String { rawValue }
    var maxOperand: Int {
        switch self {
        case .beginner: 20
        case .intermediate: 100
        case .advanced: 1000
        }
    }
}

struct MathProblem {
    let a: Int
    let b: Int
    let operation: MathOperation
    var answer: Int {
        switch operation {
        case .add: a + b
        case .subtract: a - b
        case .multiply: a * b
        case .divide: b == 0 ? 0 : a / b
        }
    }
    var prompt: String { "\(a) \(operation.rawValue) \(b) = ?" }
}

enum MathProblemGenerator {
    static func generate(operation: MathOperation, difficulty: MathDifficulty) -> MathProblem {
        let max = Swift.max(2, difficulty.maxOperand)
        switch operation {
        case .add:
            return .init(a: Int.random(in: 0..<max), b: Int.random(in: 0..<max), operation: operation)
        case .subtract:
            let x = Int.random(in: 0..<max), y = Int.random(in: 0..<max)
            return .init(a: Swift.max(x, y), b: Swift.min(x, y), operation: operation)
        case .multiply:
            let factorMax = difficulty == .beginner ? 6 : (difficulty == .intermediate ? 13 : 20)
            return .init(a: Int.random(in: 0..<factorMax), b: Int.random(in: 0..<factorMax), operation: operation)
        case .divide:
            let divisorMax = difficulty == .beginner ? 6 : (difficulty == .intermediate ? 13 : 20)
            let divisor = Int.random(in: 1..<divisorMax)
            let quotient = Int.random(in: 0..<divisorMax)
            return .init(a: divisor * quotient, b: divisor, operation: operation)
        }
    }
}
