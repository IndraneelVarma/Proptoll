import Foundation

struct Owner: Codable, Hashable, Identifiable, Equatable {
    let id: String
    let unitId: String //
    let userId: String //
    let noOfFloors: Int
   /* let adfStatus: Bool?
    let isAadharLinked: Bool?
    let tarrifCategory: String?*/
    let isActive: Bool //
    let createdAt: String //
    let updatedAt: String //
    let organizationId: Int //
    let unit: Unit? //
    let user: UserDetails? //
    let account: AccountId? //
    let customProperties: [CustomProperties]?
}


struct UserDetails: Codable, Hashable, Identifiable, Equatable{
    let id: String
    let username: String //
    let mobileNumber: String //
    let email: String?
    let name: String //
   // let organizationId: Int // compulsory property but missing in response
}

struct AccountId: Codable, Hashable, Identifiable, Equatable{
    let id: String //
    let unitsId: String //
}


struct CustomProperties: Codable, Hashable, Identifiable, Equatable{
    let id: String = UUID().uuidString
    let name: String
    let value: CustomValue
}


enum CustomValue: Codable, Hashable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case date(Date)    // Added date case
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
            return
        }
        
        // Try decoding date first (assuming ISO8601 format)
        if let dateString = try? container.decode(String.self),
           let date = ISO8601DateFormatter().date(from: dateString) {
            self = .date(date)
            return
        }
        
        // Try decoding each type in order
        if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode value")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .date(let value):
            let dateString = ISO8601DateFormatter().string(from: value)
            try container.encode(dateString)
        case .null:
            try container.encodeNil()
        }
    }
    
    // Convert to string for Realm storage
    var stringValue: String {
        switch self {
        case .string(let value): return "string:\(value)"
        case .int(let value): return "int:\(value)"
        case .double(let value): return "double:\(value)"
        case .bool(let value): return "bool:\(value)"
        case .date(let value):
            let timestamp = value.timeIntervalSince1970
            return "date:\(timestamp)"
        case .null: return "null"
        }
    }
    
    // Create from string (for Realm retrieval)
    static func fromString(_ string: String) -> CustomValue {
        let components = string.split(separator: ":", maxSplits: 1)
        guard components.count == 2 else {
            if components.first == "null" { return .null }
            return .string(string)
        }
        
        let type = String(components[0])
        let value = String(components[1])
        
        switch type {
        case "string": return .string(value)
        case "int": return .int(Int(value) ?? 0)
        case "double": return .double(Double(value) ?? 0.0)
        case "bool": return .bool(value.lowercased() == "true")
        case "date":
            if let timestamp = Double(value) {
                return .date(Date(timeIntervalSince1970: timestamp))
            }
            return .null
        default: return .string(string)
        }
    }
    
    // Helper to format date for display
    var displayValue: String {
        switch self {
        case .string(let str): return str
        case .int(let num): return String(num)
        case .double(let num): return String(format: "%.2f", num)
        case .bool(let bool): return bool ? "Yes" : "No"
        case .date(let date):
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        case .null: return "-"
        }
    }
}
