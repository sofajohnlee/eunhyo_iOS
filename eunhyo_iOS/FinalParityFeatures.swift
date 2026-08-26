import SwiftUI
import PDFKit
import PhotosUI
import UniformTypeIdentifiers

// MARK: - PDFKit viewer

struct PDFKitView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.document = PDFDocument(url: url)
        return view
    }
    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document?.documentURL != url { uiView.document = PDFDocument(url: url) }
    }
}

struct PDFInternalViewerView: View {
    let url: URL
    var body: some View { PDFKitView(url: url).navigationTitle(url.lastPathComponent).navigationBarTitleDisplayMode(.inline) }
}

struct RichPdfLibraryView: View {
    @State private var importing = false
    @State private var selectedURL: URL?
    var body: some View {
        Form {
            Section("PDF 자료") {
                Button("PDF 선택") { importing = true }
                if let selectedURL { NavigationLink("앱에서 열기: \(selectedURL.lastPathComponent)", destination: PDFInternalViewerView(url: selectedURL)) }
            }
            Section { Text("PDFKit을 이용해 선택한 PDF를 앱 내부에서 확대·축소하며 볼 수 있습니다.").foregroundStyle(.secondary) }
        }
        .navigationTitle("PDF 자료실")
        .fileImporter(isPresented: $importing, allowedContentTypes: [.pdf]) { result in
            if case .success(let url) = result { selectedURL = url }
        }
    }
}

// MARK: - Rich drawing

struct RichDrawingView: View {
    @State private var strokes: [DrawingStroke] = []
    @State private var current: [CGPoint] = []
    @State private var photoItem: PhotosPickerItem?
    @State private var backgroundData: Data?
    @State private var exporting = false
    @State private var exportDocument = PNGDocument(data: Data())
    @State private var status = ""

    var body: some View {
        VStack(spacing: 12) {
            drawingSurface
                .frame(minHeight: 420)
            HStack {
                PhotosPicker("배경 이미지 선택", selection: $photoItem, matching: .images)
                Button("마지막 획 취소") { if !strokes.isEmpty { strokes.removeLast() } }
            }
            HStack {
                Button("PNG 저장") { exportPNG() }
                Spacer()
                Button("전체 지우기", role: .destructive) { strokes.removeAll(); current.removeAll(); backgroundData = nil }
            }
            if !status.isEmpty { Text(status).font(.caption).foregroundStyle(.secondary) }
        }
        .padding()
        .navigationTitle("그림 연습")
        .onChange(of: photoItem) { _, item in Task { backgroundData = try? await item?.loadTransferable(type: Data.self); strokes.removeAll() } }
        .fileExporter(isPresented: $exporting, document: exportDocument, contentType: .png, defaultFilename: "eunhyo_drawing") { result in
            switch result { case .success: status = "PNG 파일을 저장했습니다."; case .failure: status = "PNG 저장에 실패했습니다." }
        }
    }

    private var drawingSurface: some View {
        ZStack {
            if let data = backgroundData, let image = UIImage(data: data) { Image(uiImage: image).resizable().scaledToFit() }
            Canvas { context, _ in
                for stroke in strokes { draw(stroke.points, in: &context) }
                draw(current, in: &context)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.secondary.opacity(0.3)))
        .gesture(DragGesture(minimumDistance: 0).onChanged { current.append($0.location) }.onEnded { _ in if !current.isEmpty { strokes.append(.init(points: current)); current = [] } })
    }

    private func draw(_ points: [CGPoint], in context: inout GraphicsContext) {
        guard let first = points.first else { return }
        var path = Path(); path.move(to: first); for point in points.dropFirst() { path.addLine(to: point) }
        context.stroke(path, with: .foreground, lineWidth: 6)
    }

    @MainActor private func exportPNG() {
        let renderer = ImageRenderer(content: drawingSurface.frame(width: 900, height: 1200))
        if let image = renderer.uiImage, let data = image.pngData() { exportDocument = PNGDocument(data: data); exporting = true }
    }
}

struct PNGDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.png] }
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws { data = configuration.file.regularFileContents ?? Data() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}

// MARK: - Gallery & slideshow

struct GalleryImage: Identifiable { let id = UUID(); let data: Data }

struct GallerySlideshowView: View {
    @State private var items: [PhotosPickerItem] = []
    @State private var images: [GalleryImage] = []
    @State private var index = 0
    var body: some View {
        VStack(spacing: 16) {
            PhotosPicker("사진 여러 장 선택", selection: $items, maxSelectionCount: 30, matching: .images)
            if images.isEmpty {
                ContentUnavailableView("사진을 선택하세요", systemImage: "photo.on.rectangle.angled")
            } else if let uiImage = UIImage(data: images[index].data) {
                Image(uiImage: uiImage).resizable().scaledToFit().frame(maxHeight: 520)
                Text("\(index + 1) / \(images.count)").foregroundStyle(.secondary)
                HStack { Button("이전") { index = (index - 1 + images.count) % images.count }; Spacer(); Button("다음") { index = (index + 1) % images.count } }
            }
        }
        .padding()
        .navigationTitle("갤러리·슬라이드쇼")
        .onChange(of: items) { _, newItems in Task { var loaded:[GalleryImage] = []; for item in newItems { if let data = try? await item.loadTransferable(type: Data.self) { loaded.append(.init(data: data)) } }; images = loaded; index = 0 } }
    }
}

// MARK: - Study mail

struct StudyMailView: View {
    @Environment(\.openURL) private var openURL
    @State private var recipient = ""
    @State private var subject = "은효 학습 결과"
    @State private var bodyText = "오늘의 학습 내용을 공유합니다."

    var body: some View {
        Form {
            Section("받는 사람") { TextField("이메일 주소", text: $recipient).textInputAutocapitalization(.never).keyboardType(.emailAddress) }
            Section("제목") { TextField("제목", text: $subject) }
            Section("내용") { TextEditor(text: $bodyText).frame(minHeight: 180) }
            Button("메일 앱에서 작성") { composeMail() }.disabled(recipient.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Section { Text("iOS 기본 메일 앱 또는 사용자가 설정한 mailto 처리 앱에서 작성 화면을 엽니다. 앱이 직접 메일을 전송하지는 않습니다.").font(.caption).foregroundStyle(.secondary) }
        }
        .navigationTitle("학습메일")
    }

    private func composeMail() {
        var components = URLComponents(); components.scheme = "mailto"; components.path = recipient
        components.queryItems = [URLQueryItem(name: "subject", value: subject), URLQueryItem(name: "body", value: bodyText)]
        if let url = components.url { openURL(url) }
    }
}
