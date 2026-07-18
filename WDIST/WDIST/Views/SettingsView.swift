import SwiftUI

struct SettingsView: View {
    @State private var viewModel: SettingsViewModel
    init(viewModel: SettingsViewModel) { _viewModel = State(initialValue: viewModel) }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Provider", selection: Binding(get: { viewModel.provider }, set: { viewModel.selectProvider($0) })) {
                        ForEach(AIProvider.allCases) { provider in
                            Text(provider.displayName).tag(provider)
                        }
                    }
                    .pickerStyle(.segmented)
                    SecureField(viewModel.provider.keyPlaceholder, text: $viewModel.apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit { viewModel.saveAPIKey() }
                    Button {
                        viewModel.saveAPIKey()
                    } label: {
                        Label("Save API key", systemImage: "key.fill")
                    }
                } header: {
                    Label("AI provider", systemImage: "sparkles")
                } footer: {
                    Text("Keys are stored securely on this device. You can also set GEMINI_API_KEY or OPENAI_API_KEY in the app’s launch environment.")
                }
                Section("Library") {
                    Button { Task { await viewModel.reindex() } } label: { Label("Re-index library", systemImage: "arrow.triangle.2.circlepath") }
                    Button(role: .destructive) { viewModel.confirmation = .deleteIndex } label: { Label("Delete index", systemImage: "trash") }
                }
                Section("Privacy") {
                    Label("Your index is stored on this device with SwiftData.", systemImage: "lock.fill")
                    Label("When an AI provider is configured, screenshot context is sent only to the selected provider to generate summaries and search tags.", systemImage: "sparkles")
                }
            }
            .navigationTitle("Settings")
            .overlay { if viewModel.isWorking { ProgressView("Re-indexing…").padding().background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14)) } }
            .confirmationDialog(
                "Delete your local index?",
                isPresented: Binding(
                    get: { viewModel.confirmation != nil },
                    set: { if !$0 { viewModel.confirmation = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button("Delete index", role: .destructive) {
                    viewModel.deleteIndex()
                    viewModel.confirmation = nil
                }
                Button("Cancel", role: .cancel) {
                    viewModel.confirmation = nil
                }
            } message: {
                Text("Your Photos will not be deleted. You can re-index at any time.")
            }
            .alert("API key saved", isPresented: $viewModel.didSaveAPIKey) {
                Button("Done", role: .cancel) { }
            } message: {
                Text("\(viewModel.provider.displayName) is ready to summarize new screenshots.")
            }
            .alert("Settings issue", isPresented: Binding(get: { viewModel.error != nil }, set: { if !$0 { viewModel.error = nil } })) { Button("OK", role: .cancel) {} } message: { Text(viewModel.error?.localizedDescription ?? "") }
        }
    }
}
