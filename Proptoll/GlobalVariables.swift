//
//  GlobalVariables.swift
//  Proptoll
//
//  Created by Indraneel Varma on 16/08/24.
//

import Foundation
import SwiftUI
import MatomoTracker
 
let baseApiUrl = "https://api.proptoll.com/api"
var mainSociety = "I.D.P.L. Employees Co-op. Housing Building Society"
var mainName = UserDefaults.standard.string(forKey: "mainName") ?? "Dummy Name"
var jwtToken = UserDefaults.standard.string(forKey: "jwtToken") ?? ""//this isnt the one being stored in internal storage. code for that is in OtpView
var mainPhoneNumber = UserDefaults.standard.string(forKey: "mainPhoneNumber") ?? "9876543210"
var plotId = UserDefaults.standard.string(forKey: "plotId") ?? ""
var billId = UserDefaults.standard.string(forKey: "billId") ?? ""
let matomoTracker = MatomoTracker(siteId: "1", baseURL: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)


