import Foundation
import SwiftUI
import UIKit
import Sentry

@MainActor
class NotificationViewModel: ObservableObject {
    @Published var notificationResponse: String = "empty"
    @Published var error: String?
    
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "POST")) {
        self.apiService = apiService
    }
    
    private func getDeviceID() -> String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
    }
    
    func registerNotifications(jsonQuery: [String: Any]) async {
        // Reset state
        error = nil
        notificationResponse = "empty"
        
        // Validate required data
        guard let fcmToken = try? keychain.string(forKey: "fcmToken"),
              let ownerId = UserDefaults.standard.string(forKey: "ownerId"),
              !fcmToken.isEmpty,
              !ownerId.isEmpty else {
            self.error = "Missing required registration data"
            SentrySDK.capture(message: "Missing notification registration data")
            return
        }
        
        let deviceId = getDeviceID()
        
        do {
            let data = try await apiService.getData3(
                endpoint: "pushNotifications/saveOrUpdate/\(deviceId)",
                body: createRegistrationBody(
                    deviceId: deviceId,
                    fcmToken: fcmToken,
                    ownerId: ownerId
                )
            )
            
            handleNotificationResponse(data)
            
        } catch {
            self.error = error.localizedDescription
            matomoTracker.track(
                eventWithCategory: "noti api",
                action: "error",
                name: "Error: \(self.error ?? "")",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
            SentrySDK.capture(error: error)
        }
    }
    
    private func handleNotificationResponse(_ data: Data) {
        if let notiString = String(data: data, encoding: .utf8) {
            self.notificationResponse = notiString
        } else {
            self.error = "Failed to decode notification response"
            SentrySDK.capture(message: "Failed to decode notification response")
        }
    }
    
    private func createRegistrationBody(deviceId: String, fcmToken: String, ownerId: String) -> [String: Any] {
        return [
            "fcmToken": fcmToken,
            "deviceId": deviceId,
            "ownerId": ownerId,
            "isActive": true,
            "platform": "IOS",
            "osVersion": UIDevice.current.systemVersion,
            "appBuild": "beta",
            "topic": "consumer"
        ]
    }
}
