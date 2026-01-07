import Foundation

struct LogModel: Identifiable, Codable, Hashable {
    let id: UUID
    let timestamp: Date
    let method: String
    let url: String
    let statusCode: Int
    let duration: TimeInterval
    
    let requestHeaders: [String: String]?
    let responseHeaders: [String: String]?
    
    let requestBody: String?
    let responseBody: String?
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: timestamp)
    }
    
    var isError: Bool { statusCode >= 400 }
    var host: String { URL(string: url)?.host ?? "Unknown" }
    var path: String { URL(string: url)?.path ?? "/" }
    var query: String? { URL(string: url)?.query }
}
