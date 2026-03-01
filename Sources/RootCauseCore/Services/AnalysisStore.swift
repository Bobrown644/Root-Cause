import Foundation

public protocol AnalysisStoring {
    func fetchAll() throws -> [Analysis]
    func save(_ analysis: Analysis) throws
    func delete(id: UUID) throws
    func update(_ analysis: Analysis) throws
}

public final class AnalysisStore: AnalysisStoring {
    private let fileURL: URL

    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    public init(fileURL: URL? = nil) {
        if let fileURL = fileURL {
            self.fileURL = fileURL
        } else {
            self.fileURL = Self.defaultFileURL()
        }
    }

    public func fetchAll() throws -> [Analysis] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        let data = try Data(contentsOf: fileURL)
        if data.isEmpty { return [] }
        return try JSONDecoder.appDecoder.decode([Analysis].self, from: data)
    }

    public func save(_ analysis: Analysis) throws {
        var analyses = try fetchAll()
        analyses.append(analysis)
        try persist(analyses)
    }

    public func delete(id: UUID) throws {
        var analyses = try fetchAll()
        analyses.removeAll { $0.id == id }
        try persist(analyses)
    }

    public func update(_ analysis: Analysis) throws {
        var analyses = try fetchAll()
        guard let index = analyses.firstIndex(where: { $0.id == analysis.id }) else {
            throw StoreError.analysisNotFound
        }
        analyses[index] = analysis
        try persist(analyses)
    }

    private func persist(_ analyses: [Analysis]) throws {
        let directory = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        let data = try JSONEncoder.appEncoder.encode(analyses)
        try data.write(to: fileURL, options: .atomic)
    }

    private static func defaultFileURL() -> URL {
        #if os(Linux)
        let base = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents")
        #else
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        #endif
        return base
            .appendingPathComponent("RootCause")
            .appendingPathComponent("analyses.json")
    }

    public enum StoreError: Error, LocalizedError {
        case analysisNotFound

        public var errorDescription: String? {
            switch self {
            case .analysisNotFound:
                return "Analysis not found in store."
            }
        }
    }
}
