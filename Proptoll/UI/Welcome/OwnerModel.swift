//
//  OwnerModel.swift
//  Proptoll
//
//  Created by Indraneel Varma on 23/08/24.
//

import Foundation

struct Owner: Codable, Hashable{
    let name: String
    let plots: [Plots]?
}
struct Plots: Codable, Hashable{
    let id: String?
}
