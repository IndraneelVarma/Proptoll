import Foundation
import Combine

class ReceiptsViewModel: ObservableObject {
    @Published var receipts: [Receipts] = []
    @Published var error: String?
    @Published var receiptUrl: PDF?
    
    private var cancellables = Set<AnyCancellable>()
    private let apiService: MainApiCall
    
    init(apiService: MainApiCall = MainApiCall(httpMethod: "GET")) {
        self.apiService = apiService
    }
    
    
    func fetchReceipts(jsonQuery: [String: Any]) async {
        await apiService.getData2(endpoint: "payments", jsonQuery: jsonQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] (receipts: [Receipts]) in
                DispatchQueue.main.async{
                    self?.receipts = receipts
                }
            }
            .store(in: &cancellables)
    }
    func downloadReceipts(jsonQuery: [String: Any], receiptId: String) async {
        await apiService.getData2(endpoint: "generate-pdf/receipt/\(receiptId)", jsonQuery: jsonQuery)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                    matomoTracker.track(eventWithCategory: "receipts api", action: "error", name: "Error: \(self?.error ?? "")" ,url: URL(string: "https://metapointer.matomo.cloud/matomo.php")!)
                }
            } receiveValue: { [weak self] (url: PDF) in
                DispatchQueue.main.async{
                    self?.receiptUrl = url
                }
            }
            .store(in: &cancellables)
    }
}
