import Foundation
import Combine

class PaymentsViewModel: ObservableObject {
    @Published var paymentHtml: String = "empty"
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "POST")) {
        self.apiService = apiService
    }
    
    func postPayRequest(jsonQuery: [String: Any], amount: Int) async{
        await apiService.getData3(endpoint: "initiateTransaction", body: [
            "amount": amount,
            "billing_name": mainName,
            "billing_tel": mainPhoneNumber,
            "merchant_param1": billId,
            "merchant_param2": "2001",
            "merchant_param5": "Native"
        ])
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                self?.error = error.localizedDescription
            }
        } receiveValue: { [weak self] data in
            if let htmlString = String(data: data, encoding: .utf8) {
                self?.paymentHtml = htmlString
                print("Received HTML: \(htmlString.prefix(100))...") // Print first 100 characters
            } else {
                self?.error = "Failed to decode HTML response"
            }
        }
        .store(in: &cancellables)
    }
}
