//
//  OtpResponseModel.swift
//  Proptoll
//
//  Created by Indraneel Varma on 12/08/24.
//

import Foundation

struct OTPResponse: Codable {
    let message: String
    let name: String
    let token: String
}
struct ResendResponse: Codable
{
    let message: String
}
