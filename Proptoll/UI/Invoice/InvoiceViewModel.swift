import Foundation

@MainActor
class InvoiceViewModel: ObservableObject {
    @Published var invoices: [Invoice] = []
    @Published var error: String?
    @Published var invoiceUrl: PDF?
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET")) {
        self.apiService = apiService
    }
    
    func fetchInvoices(jsonQuery: [String: Any]) async {
        do {
            error = nil
            let invoices: [Invoice] = try await apiService.getData2(endpoint: "invoice", jsonQuery: jsonQuery)
            self.invoices = invoices
            
            if invoices.isEmpty {
                error = "empty"
            }
            
            if let limit = jsonQuery["filter[limit]"] as? Int, limit == 1 {
                UserDefaults.standard.setValue(invoices.first?.id, forKey: "invoiceId")
            }
        } catch {
            self.error = error.localizedDescription
            matomoTracker.track(eventWithCategory: "invoices api",
                              action: "error",
                              name: "Error: \(self.error ?? "")",
                              url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
        }
    }
    
    func downloadInvoice(jsonQuery: [String: Any], invoiceId: String) async {
        do {
            let url: PDF = try await apiService.getData(endpoint: "generate-pdf/invoice/\(invoiceId)",
                                                      jsonQuery: jsonQuery)
            self.invoiceUrl = url
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    func downloadReceipt(jsonQuery: [String: Any], receiptId: String) async {
        do {
            let url: PDF = try await apiService.getData(endpoint: "generate-pdf/receipt/\(receiptId)",
                                                      jsonQuery: jsonQuery)
            self.invoiceUrl = url
        } catch {
            self.error = error.localizedDescription
        }
    }
}
