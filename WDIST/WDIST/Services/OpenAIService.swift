import Foundation

actor OpenAIService {
    private let session: URLSession
    private let apiKeyProvider: @Sendable () -> String?

    init(session: URLSession = .shared, apiKeyProvider: @escaping @Sendable () -> String? = { KeychainStore(service: "com.hyphen.own.WDIST").value(for: AIProvider.openAI.keychainAccount) ?? ProcessInfo.processInfo.environment["OPENAI_API_KEY"] }) {
        self.session = session
        self.apiKeyProvider = apiKeyProvider
    }

    func summarizeScreenshot(ocrText: String, imageData: Data) async throws -> AIAnalysis {
        let prompt = """
        Analyze this screenshot for a personal memory search app. Return JSON only with exactly: summary (string), category (one of Job Posts, QR Codes, Receipts, Tickets, Recipes, Memes, Notes, Maps, OTP, Event Posters, Shopping, Other), tags (string array), important_entities (string array). Be concise and preserve useful names, dates, locations, URLs, and actions. OCR text follows:\n\(ocrText)
        """
        let response = try await respond(prompt: prompt, imageData: imageData)
        return try decodeAnalysis(response)
    }

    func generateTags(for ocrText: String) async throws -> [String] {
        let response = try await respond(prompt: "Return JSON only: an array of up to 8 useful search tags for this screenshot text: \(ocrText)", imageData: nil)
        guard let data = cleanedJSON(response).data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    private func respond(prompt: String, imageData: Data?) async throws -> String {
        guard let apiKey = apiKeyProvider()?.trimmingCharacters(in: .whitespacesAndNewlines), !apiKey.isEmpty else { throw AppError.invalidAPIKey }
        guard let url = URL(string: "https://api.openai.com/v1/responses") else { throw AppError.unknown("Invalid OpenAI endpoint.") }
        var content: [[String: Any]] = [["type": "input_text", "text": prompt]]
        if let imageData {
            let dataURL = "data:image/jpeg;base64,\(imageData.base64EncodedString())"
            content.append(["type": "input_image", "image_url": dataURL, "detail": "low"])
        }
        let body: [String: Any] = [
            "model": "gpt-4.1-mini",
            "input": [["role": "user", "content": content]],
            "store": false
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw AppError.networkUnavailable }
            if http.statusCode == 400 || http.statusCode == 401 || http.statusCode == 403 { throw AppError.invalidAPIKey }
            guard 200..<300 ~= http.statusCode else { throw AppError.aiService("OpenAI is unavailable right now. Please try again.") }
            guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any], let text = outputText(from: object) else { throw AppError.aiService("OpenAI didn't return a summary.") }
            return text
        } catch let error as AppError { throw error }
        catch let error as URLError where error.code == .notConnectedToInternet || error.code == .timedOut { throw AppError.networkUnavailable }
        catch { throw AppError.aiService("Couldn't reach OpenAI. Please try again.") }
    }

    private func outputText(from object: [String: Any]) -> String? {
        let output = object["output"] as? [[String: Any]]
        let content = output?.flatMap { $0["content"] as? [[String: Any]] ?? [] }
        return content?.first { $0["type"] as? String == "output_text" }?["text"] as? String
    }

    private func decodeAnalysis(_ response: String) throws -> AIAnalysis {
        guard let data = cleanedJSON(response).data(using: .utf8) else { throw AppError.aiService("OpenAI returned an unreadable response.") }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(AIAnalysis.self, from: data)
        } catch {
            throw AppError.aiService("OpenAI returned an unexpected analysis format.")
        }
    }

    private func cleanedJSON(_ text: String) -> String {
        text.replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
