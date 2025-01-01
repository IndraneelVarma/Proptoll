//
//  UserGuideModel.swift
//  Proptoll
//
//  Created by Indraneel Varma on 09/10/24.
//

import Foundation

struct UserGuide: Codable, Equatable, Hashable{
    let name: String
    let s3ResourceUrl: String
}
