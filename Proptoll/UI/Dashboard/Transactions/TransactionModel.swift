import Foundation
import SwiftUI

struct Transaction: Codable, Hashable, Identifiable {
    let id: String
    let amount: Double
    let transactionId: String
    let transactionType: String
    let accountId: String
    let createdAt: String
    let organizationId: Int
    let event: String?
    let description: String?
}
