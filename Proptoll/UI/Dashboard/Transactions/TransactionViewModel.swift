import Foundation

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var error: String?
    @Published var invoiceUrl: PDF?
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET")) {
        self.apiService = apiService
    }
    
    func fetchTransactions(jsonQuery: [String: Any], id: String) async {
        do {
            error = nil
            let transactions: [Transaction] = try await apiService.getData2(endpoint: "/accounts/\(id)/transactions", jsonQuery: jsonQuery)
            self.transactions = transactions
            
            if transactions.isEmpty {
                error = "empty"
            }
        
        } catch {
            self.error = error.localizedDescription
            matomoTracker.track(eventWithCategory: "invoices api",
                              action: "error",
                              name: "Error: \(self.error ?? "")",
                              url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
        }
    }

}
