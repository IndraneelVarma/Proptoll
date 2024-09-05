//
//  ReceiptsModel.swift
//  Proptoll
//
//  Created by Indraneel Varma on 26/08/24.
//

import Foundation


struct Receipts: Codable, Hashable{
    let receiptNumber: Int?
    let billId: String?
    let amountPaid: Int?
    let paymentDate: String?
    let modeOfPayment: String?
    let receivedTowardsWater: Int?
    let receivedTowardsMaintenance: Int?
    let receivedTowardsSecurity: Int?
    let id: String?
}
