//
//  AccountModel.swift
//  Proptoll
//
//  Created by Indraneel Varma on 07/11/24.
//

import Foundation
import SwiftUI

struct Account: Codable, Hashable, Identifiable, Equatable{
    let id: String
    let deleted: Bool
    let accountNumber: String
    let availableBalance: Double?
    let accountName: String
    let accountType: String
    let unitsId: String
}
