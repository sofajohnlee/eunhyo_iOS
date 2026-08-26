import SwiftUI

struct SettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("largeText") private var largeText = false

    var body: some View {
        Form {
            Section("학습 설정") {
                Toggle("소리 사용", isOn: $soundEnabled)
                Toggle("큰 글씨 선호", isOn: $largeText)
            }
            Section("데이터") {
                Button("학습 진행 초기화", role: .destructive) {
                    UserDefaults.standard.removeObject(forKey: "mathCorrect")
                    UserDefaults.standard.removeObject(forKey: "mathAttempts")
                    UserDefaults.standard.removeObject(forKey: "studyNote")
                }
            }
        }.navigationTitle("설정")
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                Text("은효 학습 iOS").font(.title2.bold())
                Text("Android eunhyo2의 SwiftUI 네이티브 변환 프로젝트")
            }
            Section("기술") {
                Text("SwiftUI")
                Text("AVFoundation 음성 합성")
                Text("UserDefaults 기반 설정·학습 상태")
            }
        }.navigationTitle("앱 정보")
    }
}
