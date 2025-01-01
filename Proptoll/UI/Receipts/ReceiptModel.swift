import Foundation

struct Receipts: Codable, Hashable, Identifiable{
    let deleted: Bool
    let receiptNumber: String
    let id: String
   // let accountId: String
    let amountPaid: Double
    let source: String
    let createdAt: String
    let updatedAt: String
    let organizationId: Int
    let paymentId: String?
    let payment: Payments?
    let receivedTowards: [ReceivedTowards]
}

struct ReceivedTowards: Codable, Hashable{
    let serviceName: String
    let amount: Double?
}

struct Payments: Codable, Hashable, Identifiable {
    let deleted: Bool
    let id: String
    let modeOfPayment: String
    let amountPaid: Double
    let paymentTakenBy: String
    let paymentDate: String
    let referenceId: String?
    let ledgerId: String?
    let chequeNumber: String?
    let createdAt: String
    let updatedAt: String
    let organizationId: Int
    let transactionId: String
    let accountId: String
}

