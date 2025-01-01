import Foundation

@MainActor
class PaymentsViewModel: ObservableObject {
    @Published var paymentHtml: String = "empty"
    @Published var error: String?
    
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "POST")) {
        self.apiService = apiService
    }
    
    func postPayRequest(jsonQuery: [String: Any], amount: Int, accountId: String) async {
        // Clear previous errors
        error = nil
        
        do {
            let requestBody: [String: Any] = [
                "amount": amount,
                "billing_name": UserDefaults.standard.string(forKey: "mainName") ?? "",
                "billing_tel": UserDefaults.standard.string(forKey: "mainPhoneNumber") ?? "",
                "merchant_param1": accountId,
                "merchant_param2": UserDefaults.standard.string(forKey: "selectedUnitNumber") ?? "xxx",
                "merchant_param5": "IOS"
            ]
            
            let data = try await apiService.getData3(
                endpoint: "initiateTransaction",
                body: requestBody
            )
            
            if let htmlString = String(data: data, encoding: .utf8) {
                self.paymentHtml = htmlString
            } else {
                self.error = "Failed to decode HTML response"
            }
            
        } catch {
            self.error = error.localizedDescription
            matomoTracker.track(
                eventWithCategory: "payments api",
                action: "error",
                name: "Error: \(self.error ?? "")",
                url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!
            )
        }
    }
}
