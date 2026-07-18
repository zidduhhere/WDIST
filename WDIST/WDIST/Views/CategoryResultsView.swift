import SwiftUI

struct CategoryResultsView: View {
    let category: ScreenshotCategory
    @State private var viewModel: SearchViewModel
    @State private var selectedItem: ScreenshotItem?

    init(category: ScreenshotCategory, viewModel: SearchViewModel) {
        self.category = category
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.isSearching { ProgressView().padding(40) }
                else if viewModel.results.isEmpty { ContentUnavailableView("No \(category.rawValue.lowercased()) yet", systemImage: category.symbolName) }
                else {
                    ForEach(viewModel.results) { result in
                        ScreenshotCard(item: result.item) {
                            selectedItem = result.item
                        }
                    }
                }
            }.padding(20)
        }
        .navigationTitle(category.rawValue)
        .navigationDestination(item: $selectedItem) { ScreenshotDetailView(viewModel: DetailViewModel(item: $0)) }
        .task { viewModel.query = category.rawValue; viewModel.chooseCategory(category); await viewModel.searchNow() }
    }
}
