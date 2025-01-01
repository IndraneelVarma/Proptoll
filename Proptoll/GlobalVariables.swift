//
//  GlobalVariables.swift9848574858
//  Proptoll
//
//  Created by Indraneel Varma on 16/08/24.
//

import Foundation
import SwiftUI
import MatomoTracker
import SimpleKeychain


let baseApiUrl = "https://api.proptoll.com/api"
//let baseApiUrl = "https://api.qa.proptoll.com/api/"
//let baseApiUrl = "https://api.staging.proptoll.com/api/"
//let baseApiUrl = "https://ns.api.proptoll.com/api/"
let keychain = SimpleKeychain()
var mainSociety = "I.D.P.L. Employees Co-op. Housing Building Society"
var mainName = UserDefaults.standard.string(forKey: "mainName") ?? "Dummy Name" //no longer using variable
var jwtToken = try? keychain.string(forKey: "jwtToken") // no longer using this variable
var mainPhoneNumber = UserDefaults.standard.string(forKey: "mainPhoneNumber") ?? "9876543210"//no longer using variable
var billId = UserDefaults.standard.string(forKey: "billId") ?? ""//no longer using variable
let matomoTracker = MatomoTracker(siteId: "1", baseURL: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
var fcmToken = try? keychain.string(forKey: "fcmToken")//no longer using variable
var ownerId = UserDefaults.standard.string(forKey: "ownerId") ?? ""//no longer using variable
var refresh = false
var whatsNewShown = true
var languageIndex = 0
