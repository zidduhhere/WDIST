import SwiftUI
import SwiftData

@main
struct WhereDidISeeThatApp: App {
    private let container: ModelContainer
    private let dependencies: AppDependencies
    private let storageRecoveryMessage: String?

    init() {
        do {
            container = try ModelContainer(for: ScreenshotItem.self)
            storageRecoveryMessage = nil
        } catch {
            // A broken local store should never prevent the app from launching.
            let fallbackConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                container = try ModelContainer(for: ScreenshotItem.self, configurations: fallbackConfiguration)
                storageRecoveryMessage = "Your local index needs to be rebuilt. Re-indexing will restore it."
            } catch {
                fatalError("Unable to create the screenshot index: \(error.localizedDescription)")
            }
        }
        dependencies = AppDependencies(modelContainer: container)
    }

    var body: some Scene {
        WindowGroup {
            AppRootView(dependencies: dependencies, storageRecoveryMessage: storageRecoveryMessage)
        }
        .modelContainer(container)
    }
}
