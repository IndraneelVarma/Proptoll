//
//  ProfileModel.swift
//  Proptoll
//
//  Created by Indraneel Varma on 19/08/24.
//

import Foundation

struct Profile: Codable{
    let isAadharLinked: Bool
    let tarrifCategory: String
    let adfStatus: Bool
    let noOfFloors: Int
    let plotNumber: String
}
