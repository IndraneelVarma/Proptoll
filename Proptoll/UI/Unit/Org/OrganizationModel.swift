struct Organization: Codable, Hashable, Equatable {
    let organizationName: String
    let addressLine1: String
    let addressLine2: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
    let contactNo: String
}
