import SwiftUI

struct Unit: Codable, Hashable, Identifiable, Equatable {
    let id: String
    let unitNumber: String //
    let unitType: String //
    let isCompoundUnit: Bool
    let isAvailable: Bool //
    let statusCode: Int //
    let organizationId: Int //
}
