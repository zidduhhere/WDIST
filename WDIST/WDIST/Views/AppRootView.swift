import SwiftUI

struct AppRootView: View {
    let dependencies: AppDependencies
    let storageRecoveryMessage: String?

    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                HomeView(viewModel: HomeViewModel(indexing: dependencies.indexing, searchService: dependencies.search), searchService: dependencies.search)
                    .tabItem { Label("Memories", systemImage: "sparkle.magnifyingglass") }
                SettingsView(viewModel: SettingsViewModel(settings: dependencies.settings, repository: dependencies.repository, indexing: dependencies.indexing))
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
            if let storageRecoveryMessage {
                Label(storageRecoveryMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: Capsule())
                    .padding(.top, 8)
                    .accessibilityAddTraits(.isStaticText)
            }
        }
        .tint(.blue)
    }
}
