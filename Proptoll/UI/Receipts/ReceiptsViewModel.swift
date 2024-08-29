import Foundation
import Combine

class ReceiptsViewModel: ObservableObject {
    @Published var receipts: [Receipts] = []
    @Published var error: String?
    
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
                self?.receipts = receipts
                
            }
            .store(in: &cancellables)
    }
    func filteredBills(searchText: String) async { //useless for now, might be of use when we add search
        if !searchText.isEmpty {
            let jsonQuery: [String: Any]
            let check = searchText.allSatisfy{ $0.isNumber }
            if check{
                jsonQuery = [
                    "filter[order]": "id DESC",
                    "filter[limit]": 50,
                    "filter[offset]": 0,
                    "filter[where][postNumber]": searchText,
                ]
            }
            else{
                jsonQuery = [
                    "filter[order]": "id DESC",
                    "filter[limit]": 50,
                    "filter[offset]": 0,
                    "filter[where][title][like]": searchText,
                ]
            }
            self.receipts.removeAll()
            await fetchReceipts(jsonQuery: jsonQuery)
           
        }
    }
}
