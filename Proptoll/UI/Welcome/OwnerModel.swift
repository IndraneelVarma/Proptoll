//
//  OwnerModel.swift
//  Proptoll
//
//  Created by Indraneel Varma on 23/08/24.
//

import Foundation

struct Owner: Codable, Hashable, Equatable{
    let name: String
    let plots: [Plots]?
}
struct Plots: Codable, Hashable, Equatable{
    let id: String?
}
