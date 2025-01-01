import Foundation

@MainActor
class ReceiptsViewModel: ObservableObject {
    @Published var receipts: [Receipts] = []
    @Published var error: String?
    @Published var receiptUrl: PDF?
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET")) {
        self.apiService = apiService
    }
    
    func fetchReceipts(jsonQuery: [String: Any]) async {
        do {
            error = nil
            let receipts: [Receipts] = try await apiService.getData2(endpoint: "mobile-receipts", jsonQuery: jsonQuery)
            self.receipts = receipts
            
            if receipts.isEmpty {
                error = "empty"
            }
        } catch {
            self.error = error.localizedDescription
            matomoTracker.track(eventWithCategory: "receipts api",
                              action: "error",
                              name: "Error: \(self.error ?? "")",
                              url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
        }
    }
    
    func downloadReceipt(jsonQuery: [String: Any], receiptId: String) async {
        do {
            let url: PDF = try await apiService.getData(endpoint: "generate-pdf/new-receipt/\(receiptId)",
                                                      jsonQuery: jsonQuery)
            self.receiptUrl = url
        } catch {
            self.error = error.localizedDescription
        }
    }
}
