import SwiftUI

struct SearchView: View {
    @State private var viewModel: SearchViewModel
    @State private var selectedItem: ScreenshotItem?
    @FocusState private var isSearchFocused: Bool

    init(viewModel: SearchViewModel) { _viewModel = State(initialValue: viewModel) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                searchField
                categoryPicker
                searchContent
            }
            .padding(20)
        }
        .navigationTitle("Search memories")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedItem) { ScreenshotDetailView(viewModel: DetailViewModel(item: $0)) }
        .task { isSearchFocused = true }
        .alert("Search issue", isPresented: Binding(get: { viewModel.error != nil }, set: { if !$0 { viewModel.error = nil } })) { Button("OK", role: .cancel) {} } message: { Text(viewModel.error?.localizedDescription ?? "") }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("What do you remember?", text: $viewModel.query, axis: .vertical)
                .focused($isSearchFocused)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.search)
                .onSubmit { Task { await viewModel.searchNow() } }
            if !viewModel.query.isEmpty { Button { viewModel.query = "" } label: { Image(systemName: "xmark.circle.fill").foregroundStyle(.tertiary) } }
        }
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                SearchFilterChip(title: "Everything", isSelected: viewModel.selectedCategory == nil) { viewModel.chooseCategory(nil) }
                ForEach(ScreenshotCategory.allCases.filter { $0 != .other }) { category in
                    SearchFilterChip(title: category.rawValue, symbol: category.symbolName, isSelected: viewModel.selectedCategory == category) { viewModel.chooseCategory(category) }
                }
            }
        }
    }

    @ViewBuilder private var searchContent: some View {
        if viewModel.isSearching {
            HStack { ProgressView(); Text("Looking through your memories…").foregroundStyle(.secondary) }.frame(maxWidth: .infinity).padding(.vertical, 36)
        } else if viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            SearchPromptView()
        } else if viewModel.results.isEmpty {
            ContentUnavailableView("No matching memories", systemImage: "sparkle.magnifyingglass", description: Text("Try a person, place, topic, or a detail you remember."))
                .padding(.vertical, 48)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Best matches").font(.headline)
                ForEach(viewModel.results) { result in
                    ScreenshotCard(item: result.item, matchTerms: result.highlights) { selectedItem = result.item }
                }
            }
        }
    }
}
