import SwiftUI

struct ScreenshotDetailView: View {
    @State private var viewModel: DetailViewModel
    @Environment(\.openURL) private var openURL

    init(viewModel: DetailViewModel) { _viewModel = State(initialValue: viewModel) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ScreenshotPreview(item: viewModel.item).frame(maxWidth: .infinity).frame(height: 360)
                summarySection
                ocrSection
                actions
            }.padding(20)
        }
        .navigationTitle("Screenshot")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Copy OCR text", isPresented: $viewModel.didRequestCopy) { Button("Done", role: .cancel) {} } message: { Text("Select the text below and use the system Copy action. This keeps the app free of non-SwiftUI clipboard APIs.") }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack { CategoryBadge(category: viewModel.item.category); Spacer(); Text(viewModel.item.capturedAt.memoryDisplay).font(.subheadline).foregroundStyle(.secondary) }
            Text(viewModel.item.summary).font(.title3.weight(.semibold)).fixedSize(horizontal: false, vertical: true)
            TagWrap(tags: viewModel.item.tags)
        }
    }

    private var ocrSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Recognized text", systemImage: "text.viewfinder").font(.headline)
            Text(viewModel.item.ocrText).font(.subheadline).foregroundStyle(.secondary).textSelection(.enabled).padding(16).frame(maxWidth: .infinity, alignment: .leading).background(.quaternary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var actions: some View {
        VStack(spacing: 10) {
            shareButton
            Button { viewModel.prepareCopy() } label: { Label("Copy OCR", systemImage: "doc.on.doc") }.buttonStyle(.bordered).frame(maxWidth: .infinity)
            if !viewModel.item.isDemo, let photosURL = URL(string: "photos-redirect://") {
                Button { openURL(photosURL) } label: { Label("Open in Photos", systemImage: "photo.on.rectangle") }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
            }
        }
        .controlSize(.large)
    }

    @ViewBuilder private var shareButton: some View {
        if let thumbnailData = viewModel.item.thumbnailData {
            ShareLink(
                item: ScreenshotShareItem(data: thumbnailData),
                subject: Text(viewModel.item.summary),
                message: Text(viewModel.item.summary)
            ) {
                Label("Share Screenshot", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        } else {
            ShareLink(item: viewModel.item.ocrText, subject: Text(viewModel.item.summary), message: Text(viewModel.item.summary)) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
    }
}
