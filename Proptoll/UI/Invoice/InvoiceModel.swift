//
//  InvoiceModel.swift
//  Proptoll
//
//  Created by Assistant on 05/11/24.
//

import Foundation


// Model for grouping invoices by month
struct MonthGroup: Identifiable {
    let id: String
    let month: String
    let invoices: [Invoice]
    
    init(month: String, invoices: [Invoice]) {
        self.id = month
        self.month = month
        self.invoices = invoices
    }
}


struct Invoice: Codable, Hashable, Identifiable {
    let id: String
    let isPaid: Bool?
    let invoiceTo: String
    let invoiceMonth: String
    let invoiceYear: Int
    let invoiceStatus: String
    let invoiceGroup: String
    let invoiceNumber: String
    let totalAmount: Double
    //let notes: String
    let dueDate: String
    let issuedDate: String
    //let invoiceType: String
    let transaction: Transaction?
    let invoiceItems: [InvoiceItems]?
    let payments: Payments?
    let updatedAt: String
}

struct InvoiceItems: Codable, Hashable, Identifiable {
    let id: String
    let serviceName: String?
    let costPerUnit: Double?
    let GST: Double?
    let TDS: Double?
    let previousReading: Int?
    let presentReading: Int?
    let discount: Double?
    let totalAmount: Double?
    let quantity: Int? //Units Billed: custom for water, below present reading
    let createdAt: String?
    let organizationId: Int?
    let invoiceId: String?
    let updatedAt: String?
    let invoiceServiceId: String?
    let description: String?
}


