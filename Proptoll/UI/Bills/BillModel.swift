//
//  BillModel.swift
//  Proptoll
//
//  Created by Indraneel Varma on 22/08/24.
//

import Foundation

struct Bill: Codable, Hashable {
    let dueAmount: Int
    let totalPayable: Int
    let billMonth: String
    let isPaymentDone: Bool
    let billYear: Int
    let billNumber: String
    let dueDate: String
    let lateCharges: Int
    let unitsConsumed: Int
    let waterOpeningBalance: Int
    let waterClosingBalance: Int
    let maintenanceOpeningBalance: Int
    let maintenanceClosingBalance: Int
    let securityOpeningBalance: Int
    let securityClosingBalance: Int
    let _20kl: Int
    let adfWater: Int
    let adfSecurity: Int
    let adfMaintenance: Int
    let grossWaterCharges: Int
    let grossMaintenanceCharges: Int
    let grossSecurityCharges: Int
    let totalWaterCharges: Int
    let totalMaintenanceCharges: Int
    let totalSecurityCharges: Int
    let id: String
    let createdAt: String
    let billPaidOn: String?
    let payments: [Payment]?
}

struct Payment: Codable, Hashable{
    let amountPaid: Int?
}

struct PDF: Codable, Equatable{
    let URL: String
}
