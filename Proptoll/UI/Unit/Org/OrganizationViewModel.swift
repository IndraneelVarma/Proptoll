import Foundation

@MainActor
class OrganizationViewModel: ObservableObject {
    @Published var organization: [Organization] = []
    @Published var error: String?
    @Published var realmSaveSuccessful: Bool = false
    
    private let apiService: MainApiCall
    private let realmManager: OrgRealmManager
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET"),
         realmManager: OrgRealmManager = OrgRealmManager()) {
        self.apiService = apiService
        self.realmManager = realmManager
    }
    
    func fetchOrg(jsonQuery: [String: Any]) async {
        // Reset state
        error = nil
        realmSaveSuccessful = false
        
        do {
            let organizations: [Organization] = try await apiService.getData2(
                endpoint: "organizations",
                jsonQuery: jsonQuery
            )
            
            // Update the published properties
            organization = organizations
            UserDefaults.standard.set(organizations.first?.organizationName, forKey: "organization")
            
            // Handle Realm operations
            handleRealmSave(organizations: organizations)
            
        } catch {
            self.error = error.localizedDescription
            self.realmSaveSuccessful = false
            matomoTracker.track(
                eventWithCategory: "organization api",
                action: "error",
                name: "Error: \(self.error ?? "")",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
        }
    }
    
    private func handleRealmSave(organizations: [Organization]) {
        if let firstOrg = organizations.first {
            // Delete existing organizations before adding new one
            self.realmManager.deleteAllOrganizations()
            
            // Add the new organization to Realm
            do {
                self.realmManager.addOrganization(firstOrg)
                self.realmSaveSuccessful = true
            } 
        } else {
            self.realmSaveSuccessful = false
        }
    }
    
    // Convenience method to get stored organization from Realm
    func getStoredOrganization() -> Organization? {
        guard let realmOrg = self.realmManager.organizations.first else {
            return nil
        }
        return realmOrg.toModel()
    }
    
    // Method to check if organization exists in Realm
    func hasStoredOrganization() -> Bool {
        return !self.realmManager.organizations.isEmpty
    }
}
