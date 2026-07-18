import Foundation
import Observation
import Security

@MainActor
@Observable
final class SettingsStore {
    private let keychain = KeychainStore(service: "com.hyphen.own.WDIST")
    private(set) var provider: AIProvider
    private(set) var apiKey = ""

    init() {
        provider = AIProvider(rawValue: keychain.value(for: "ai-provider") ?? "") ?? .gemini
        apiKey = keychain.value(for: provider.keychainAccount) ?? environmentKey(for: provider) ?? ""
    }

    func selectProvider(_ provider: AIProvider) throws {
        try keychain.save(provider.rawValue, for: "ai-provider")
        self.provider = provider
        apiKey = keychain.value(for: provider.keychainAccount) ?? environmentKey(for: provider) ?? ""
    }

    func saveAPIKey(_ key: String) throws {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { try keychain.remove(provider.keychainAccount) } else { try keychain.save(trimmed, for: provider.keychainAccount) }
        apiKey = trimmed
    }

    private func environmentKey(for provider: AIProvider) -> String? {
        switch provider {
        case .gemini: ProcessInfo.processInfo.environment["GEMINI_API_KEY"]
        case .openAI: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
        }
    }
}

struct KeychainStore: Sendable {
    nonisolated let service: String

    nonisolated init(service: String) { self.service = service }

    nonisolated func value(for account: String) -> String? {
        let query = [kSecClass: kSecClassGenericPassword, kSecAttrService: service, kSecAttrAccount: account, kSecReturnData: true] as CFDictionary
        var item: CFTypeRef?
        guard SecItemCopyMatching(query, &item) == errSecSuccess, let data = item as? Data else { return nil }
        return String(decoding: data, as: UTF8.self)
    }

    nonisolated func save(_ value: String, for account: String) throws {
        let data = Data(value.utf8)
        let query = [kSecClass: kSecClassGenericPassword, kSecAttrService: service, kSecAttrAccount: account] as CFDictionary
        let update = [kSecValueData: data] as CFDictionary
        let status = SecItemUpdate(query, update)
        if status == errSecItemNotFound {
            let addition = [kSecClass: kSecClassGenericPassword, kSecAttrService: service, kSecAttrAccount: account, kSecValueData: data] as CFDictionary
            guard SecItemAdd(addition, nil) == errSecSuccess else { throw AppError.unknown("Unable to save the API key securely.") }
        } else if status != errSecSuccess { throw AppError.unknown("Unable to update the API key securely.") }
    }

    nonisolated func remove(_ account: String) throws {
        let query = [kSecClass: kSecClassGenericPassword, kSecAttrService: service, kSecAttrAccount: account] as CFDictionary
        let status = SecItemDelete(query)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw AppError.unknown("Unable to remove the API key.") }
    }
}
