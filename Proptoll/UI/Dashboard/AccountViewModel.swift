import Foundation

@MainActor
class AccountViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var error: String?
    
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET")) {
        self.apiService = apiService
    }
    
    func fetchAccounts(jsonQuery: [String: Any]) async {
        // Reset state
        error = nil
        accounts.removeAll()
        
        // Validate unit ID
        guard let unitId = UserDefaults.standard.string(forKey: "selectedUnitId"), !unitId.isEmpty else {
            error = "No unit selected"
            return
        }
        
        do {
            let account: Account = try await apiService.getData2(
                endpoint: "units/\(unitId)/account",
                jsonQuery: jsonQuery
            )
            
            // Handle successful response
            handleAccountResponse(account: account, jsonQuery: jsonQuery)
        } catch {
            self.error = error.localizedDescription
            matomoTracker.track(
                eventWithCategory: "accounts api",
                action: "error",
                name: "Error: \(self.error ?? "")",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
        }
    }
    
    private func handleAccountResponse(account: Account, jsonQuery: [String: Any]) {
        accounts.append(account)
        //UserDefaults.standard.setValue(account.id, forKey: "accountId")
        try? keychain.set(account.id, forKey: "accountId")
    }
}
