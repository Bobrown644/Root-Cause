import Foundation

struct _AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}

extension Decoder {
    func rejectUnknownKeys<T: CodingKey & CaseIterable>(for type: T.Type) throws {
        let rawContainer = try self.container(keyedBy: _AnyCodingKey.self)
        let known = Set(T.allCases.map { $0.stringValue })
        let actual = Set(rawContainer.allKeys.map { $0.stringValue })
        let extras = actual.subtracting(known)
        guard extras.isEmpty else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: rawContainer.codingPath,
                debugDescription: "Unexpected keys: \(extras.sorted().joined(separator: ", "))"
            ))
        }
    }
}
