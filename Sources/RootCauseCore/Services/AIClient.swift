import Foundation

public protocol AIClient: Sendable {
    func complete(systemPrompt: String, userPrompt: String) async throws -> String
}

public enum AIClientError: Error, LocalizedError {
    case emptyResponse
    case invalidJSON(underlying: Error)

    public var errorDescription: String? {
        switch self {
        case .emptyResponse:
            return "AI client returned an empty response."
        case .invalidJSON(let underlying):
            return "AI response is not valid JSON: \(underlying.localizedDescription)"
        }
    }
}
