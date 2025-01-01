import Foundation
import SwiftUI
import UIKit

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var paymentHtml: String = "empty"
    @Published var error: String?
    
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "PATCH")) {
        self.apiService = apiService
    }
    
    private func getDeviceID() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
    }
    
    func unRegisterNotifications(jsonQuery: [String: Any]) async {
        // Clear previous errors
        error = nil
        
        do {
            let deviceId = getDeviceID()
            let data = try await apiService.getData3(
                endpoint: "pushNotifications/userLogout/\(deviceId)",
                body: [:]
            )
            
            if let notiString = String(data: data, encoding: .utf8) {
                self.paymentHtml = notiString
            } else {
                self.error = "Failed to decode noti response"
            }
            
        } catch {
            self.error = error.localizedDescription
            matomoTracker.track(
                eventWithCategory: "noti logout api",
                action: "error",
                name: "Error: \(self.error ?? "")",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
        }
    }
}
