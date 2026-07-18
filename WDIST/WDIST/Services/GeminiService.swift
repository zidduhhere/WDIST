import Foundation

actor GeminiService {
    private let session: URLSession
    private let apiKeyProvider: @Sendable () -> String?

    init(session: URLSession = .shared, apiKeyProvider: @escaping @Sendable () -> String? = { KeychainStore(service: "com.hyphen.own.WDIST").value(for: "gemini-api-key") ?? ProcessInfo.processInfo.environment["GEMINI_API_KEY"] }) {
        self.session = session
        self.apiKeyProvider = apiKeyProvider
    }

    func summarizeScreenshot(ocrText: String, imageData: Data) async throws -> AIAnalysis {
        let text = """
        Summarize this screenshot for a personal memory search app. Return JSON only with exactly: summary (string), category (one of Job Posts, QR Codes, Receipts, Tickets, Recipes, Memes, Notes, Maps, OTP, Event Posters, Shopping, Other), tags (string array), important_entities (string array). Be concise and preserve useful names, dates, locations, URLs, and actions. OCR text follows:\n\(ocrText)
        """
        let response = try await generate(prompt: text, imageData: imageData)
        guard let data = cleanedJSON(from: response).data(using: .utf8) else { throw AppError.aiService("Gemini returned an unreadable response.") }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(AIAnalysis.self, from: data)
        }
        catch { throw AppError.aiService("Gemini returned an unexpected analysis format.") }
    }

    func generateTags(for ocrText: String) async throws -> [String] {
        let response = try await generate(prompt: "Return JSON only: an array of up to 8 useful search tags for this screenshot text: \(ocrText)", imageData: nil)
        guard let data = cleanedJSON(from: response).data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    func semanticSearch(query: String, candidates: [SearchCandidate]) async -> [String: Double] {
        // Local ranking remains private and instant. Gemini can enrich a query when a key is available.
        Dictionary(uniqueKeysWithValues: candidates.map { ($0.id, SearchScorer.score(query: query, candidate: $0)) })
    }

    private func generate(prompt: String, imageData: Data?) async throws -> String {
        guard let apiKey = apiKeyProvider()?.trimmingCharacters(in: .whitespacesAndNewlines), !apiKey.isEmpty else { throw AppError.invalidAPIKey }
        guard var components = URLComponents(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent") else { throw AppError.unknown("Invalid Gemini endpoint.") }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        guard let url = components.url else { throw AppError.unknown("Invalid Gemini endpoint.") }
        var parts: [[String: Any]] = [["text": prompt]]
        if let imageData { parts.append(["inline_data": ["mime_type": "image/jpeg", "data": imageData.base64EncodedString()]]) }
        let body: [String: Any] = ["contents": [["parts": parts]], "generationConfig": ["responseMimeType": "application/json", "temperature": 0.2]]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw AppError.networkUnavailable }
            if http.statusCode == 400 || http.statusCode == 401 || http.statusCode == 403 { throw AppError.invalidAPIKey }
            guard 200..<300 ~= http.statusCode else { throw AppError.aiService("Gemini is unavailable right now. Please try again.") }
            let decoded = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let candidates = decoded?["candidates"] as? [[String: Any]]
            let content = candidates?.first?["content"] as? [String: Any]
            let responseParts = content?["parts"] as? [[String: Any]]
            guard let text = responseParts?.first?["text"] as? String else { throw AppError.aiService("Gemini didn't return a summary.") }
            return text
        } catch let error as AppError { throw error }
        catch let error as URLError where error.code == .notConnectedToInternet || error.code == .timedOut { throw AppError.networkUnavailable }
        catch { throw AppError.aiService("Couldn't reach Gemini. Please try again.") }
    }

    private func cleanedJSON(from text: String) -> String {
        text.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
