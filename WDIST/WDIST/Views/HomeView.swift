import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @State private var searchViewModel: SearchViewModel
    @State private var isShowingSearch = false
    @State private var selectedItem: ScreenshotItem?

    init(viewModel: HomeViewModel, searchService: SearchService) {
        _viewModel = State(initialValue: viewModel)
        _searchViewModel = State(initialValue: SearchViewModel(service: searchService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    hero
                    searchButton
                    indexingStatus
                    recentSection
                    categoriesSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(.background)
            .navigationDestination(isPresented: $isShowingSearch) { SearchView(viewModel: searchViewModel) }
            .navigationDestination(item: $selectedItem) { ScreenshotDetailView(viewModel: DetailViewModel(item: $0)) }
            .task { await viewModel.load() }
            .onAppear { viewModel.refresh() }
            .refreshable { await viewModel.reindex() }
            .alert("Something needs attention", isPresented: Binding(get: { viewModel.error != nil }, set: { if !$0 { viewModel.error = nil } })) { Button("OK", role: .cancel) {} } message: { Text(viewModel.error?.localizedDescription ?? "") }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Where Did I See That?")
                .font(.largeTitle.bold())
            Text("Search your memories, not your screenshots.")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 16)
    }

    private var searchButton: some View {
        Button { isShowingSearch = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass").font(.title3).foregroundStyle(.tint)
                Text("What do you remember?").foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "sparkles").foregroundStyle(.tint)
            }
            .font(.body)
            .padding(18)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens memory search")
    }

    @ViewBuilder private var indexingStatus: some View {
        if viewModel.indexingState.isRunning {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Indexing screenshots", systemImage: "sparkles")
                    Spacer()
                    Text("\(viewModel.indexingState.completed) of \(viewModel.indexingState.total)")
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                ProgressView(value: viewModel.indexingState.progress)
                Text(viewModel.indexingState.currentSummary).font(.footnote).foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    @ViewBuilder private var recentSection: some View {
        if !viewModel.recent.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(title: "Recently indexed", subtitle: "Your latest saved memories")
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.recent) { item in
                        ScreenshotCard(item: item) { selectedItem = item }
                    }
                }
            }
        } else if !viewModel.indexingState.isRunning {
            EmptyIndexView(action: { Task { await viewModel.retryPhotoAccess() } })
        }
    }

    @ViewBuilder private var categoriesSection: some View {
        if !viewModel.categories.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                SectionTitle(title: "Categories", subtitle: "A quieter way to browse")
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(viewModel.categories) { categoryCount in
                        NavigationLink { CategoryResultsView(category: categoryCount.category, viewModel: searchViewModel) } label: {
                            CategoryCard(category: categoryCount.category, count: categoryCount.count)
                        }.buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
