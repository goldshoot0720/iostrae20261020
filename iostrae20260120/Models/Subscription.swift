import Foundation

struct Subscription: Identifiable, Codable {
    let id: String
    let name: String
    let site: String
    let price: Int
    let nextdate: String
    let note: String?
    let account: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case name
        case site
        case price
        case nextdate
        case note
        case account
        case createdAt = "$createdAt"
        case updatedAt = "$updatedAt"
    }
    
    var nextDateObject: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: nextdate) {
            return date
        }
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: nextdate)
    }
}

struct SubscriptionListResponse: Codable {
    let total: Int
    let documents: [Subscription]
}
