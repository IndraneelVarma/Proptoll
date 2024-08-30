//
//  PaymentsModel.swift
//  Proptoll
//
//  Created by Indraneel Varma on 29/08/24.
//

import Foundation


struct PaymentBody: Codable, Hashable{
    var amount: Int
    var billing_name: String
    var billing_tel: String
    var merchant_param1: String
    var merchant_param2: String
    var merchant_param5: String
}
