import Foundation
import SwiftUI
import UIKit
import Sentry

@MainActor
class EditEmailViewModel: ObservableObject {
    @Published var updatedEmail: String?
    @Published var error: String?
    @Published var isSuccess: Bool = false
    
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "PATCH")) {
        self.apiService = apiService
    }
    
    func updateEmail(newEmail: String, ownerId: String) async {
        do {
        
            let data = try await apiService.getData3(
                endpoint: "user/\(ownerId)",
                body: ["email": newEmail]
            )
            
            // Process response
            guard let result = String(data: data, encoding: .utf8) else {
                throw NSError(
                    domain: "EditEmailViewModel",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to decode response as string"]
                )
            }
            
            // Update state and UserDefaults
            self.updatedEmail = result
            self.isSuccess = true
            //UserDefaults.standard.set(newEmail, forKey: "mainEmail")
            try? keychain.set(newEmail, forKey: "mainEmail")
            
            // Track success
            matomoTracker.track(
                eventWithCategory: "email update api",
                action: "success",
                name: "Email updated api called",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
            
        } catch {
            // Handle error
            self.error = error.localizedDescription
            self.isSuccess = false
            
            // Track error
            matomoTracker.track(
                eventWithCategory: "email update api",
                action: "error",
                name: "Error: \(self.error ?? "")",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
        }
    }
}
